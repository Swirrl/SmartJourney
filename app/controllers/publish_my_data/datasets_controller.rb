module PublishMyData
  class DatasetsController < ApplicationController

    before_filter :log_subdomain
    def log_subdomain
      Rails.logger.info "SUBDOMAIN #{request.subdomain}"
    end

  end
end