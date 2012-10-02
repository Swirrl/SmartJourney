class ApplicationController < ActionController::Base

  before_filter :log_subdomain

  layout 'app'

  protect_from_forgery

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end

  private

  def log_subdomain
    Rails.logger.info "SUBDOMAIN #{request.subdomain}"
  end

end
