# encoding: utf-8
module Triploid
  module Errors

    # Raised when querying the database for a document by a specific id.
    class ResourceNotFound < StandardError
    end

  end
end
