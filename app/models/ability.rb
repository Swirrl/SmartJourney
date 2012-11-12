class Ability
  include CanCan::Ability

  def initialize(user)

    # if logged in.
    if user
      if user.role?(:super_user)
        can :manage, Report
        can :manage, :planned_incident
        can :manage, Comment
      else
        can :update, Report do |r|
          uri_matches = (r.creator && (r.creator.uri.to_s == user.uri.to_s))
          uri_matches #can only update reports reported by themselves
        end

        can :destroy, Comment do |c|
          uri_matches = (c.creator && (c.creator.uri.to_s == user.uri.to_s))
          uri_matches # can only destroy comments created by themselves
        end

      end
      can :create, Comment # need to be logged in to comment.

    end

    # all users can create and read reports.
    can [:create, :read], Report

    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end
end
