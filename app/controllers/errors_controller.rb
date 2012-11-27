#http://accuser.cc/posts/1-rails-3-0-exception-handling
class ErrorsController < ApplicationController
  def routing
     raise Tripod::Errors::ResourceNotFound
  end
end