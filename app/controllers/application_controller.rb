class ::ApplicationController < ActionController::Base

  layout 'app'

  protect_from_forgery

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.html {redirect_to root_url, :alert => exception.message}
      format.json {head :unauthorized}
    end
  end

  private

  def current_ability
    # pass the request into the Ability.
    @current_ability ||= Ability.new(current_user, request.format, request.headers['api-key'])
  end

end
