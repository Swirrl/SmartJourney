class Ability
  include CanCan::Ability

  def initialize(user, format)

    # if logged in.
    if user
      if user.role?(:super_user)
        can :manage, Report
        can :manage, :planned_incident
        can :manage, Comment
      else
        can :update, Report do |r|
          uri_matches = (r.creator && (r.creator.uri.to_s == user.uri.to_s))
          Rails.logger.debug r.creator.screen_name if r.creator
          Rails.logger.debug "Matches? #{uri_matches.to_s}"
          uri_matches #can only update reports reported by themselves
        end

        can :destroy, Comment do |c|
          uri_matches = (c.creator && (c.creator.uri.to_s == user.uri.to_s))
          uri_matches # can only destroy comments created by themselves
        end

      end
      can :create, Comment # need to be logged in to comment.
      can :create, Report # here to support non-html report creation
    else
      # If not logged in, can create reports thru HTML ONLY.
      can(:create, Report) if format.to_s =~ /html/
    end

    can :read, Report # anyone can read reports.

    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end
end
