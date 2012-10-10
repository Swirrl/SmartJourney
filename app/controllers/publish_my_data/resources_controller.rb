module PublishMyData
  class ResourcesController < ApplicationController
    caches_action :show, :if => false

    caches_action :doc, :if => false

    caches_action :def, :if => false
  end
end