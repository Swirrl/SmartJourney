class ::ApplicationController < ActionController::Base

  layout 'app'

  before_filter :sign_in_api_user

  protect_from_forgery

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.html {redirect_to root_url, :alert => exception.message}
      format.json {head :unauthorized}
    end
  end

  rescue_from Tripod::Errors::ResourceNotFound do |exc|
    respond_to do |format|
      format.html {render :file => Rails.root.join('public','404.html'), :layout => nil }
      format.json {head :not_found}
    end
  end

  private

  def sign_in_api_user
    if request.headers['api-key']
      user = User.where(:api_key => request.headers['api-key']).first
      if user
        sign_in user
      end
    end
  end

  def current_ability
    # pass the request into the Ability.
    @current_ability ||= Ability.new(current_user, request.format)
  end

end
