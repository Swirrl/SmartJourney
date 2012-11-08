class Ability
  include CanCan::Ability

  def initialize(user)

    Rails.logger.debug( "IN CHECK ABILITY" )

    # if logged in.
    if user

      Rails.logger.debug "logged in as #{user.screen_name}"

      if user.role?(:super_user)
        Rails.logger.debug "super user"
        can :manage, Report
        can :manage, :planned_incident

      else
        Rails.logger.debug "not super user"
        can :update, Report do |r|
          uri_matches = (r.creator && (r.creator.uri.to_s == user.uri.to_s))
          Rails.logger.debug("URI match #{uri_matches}")
          uri_matches #can only update reports reported by themselves
        end
      end
    else
      Rails.logger.debug "not logged in"
    end

    # all users can create and read reports.
    can [:create, :read], Report


    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user permission to do.
    # If you pass :manage it will apply to every action. Other common actions here are
    # :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. If you pass
    # :all it will apply to every resource. Otherwise pass a Ruby class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end
end
