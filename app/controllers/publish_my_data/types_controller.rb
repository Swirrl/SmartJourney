module PublishMyData
  class ResourcesController < ApplicationController
    caches_action :show, :if => false
  end
end