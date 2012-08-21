# encoding: utf-8
module Triploid

  # class level finders.
  module Finders

    # Find all +Resource+s of this type
    def all

    end

    # Find a +Resource+ by it's uri.
    # Raises a Triploid::Errors::ResourceNotFound exception if there are no triples in the db
    # with the uri as their subject.
    #
    # @example Find a single resource by a uri.
    #   Person.find('http://ricroberts.com#me')
    #
    # @param [ String ] uri The uri of the resource to find
    #
    # @return [ Document, nil, Criteria ] A document or matching documents.
    def find(uri)
      triples = Triploid::SparqlClient.describe("DESCRIBE <#{uri}>")

      puts triples.inspect

      if triples.empty?
        raise Triploid::Errors::ResourceNotFound.new
      else
        # load the results into an instance of a resource, and return that.
      end
    end

    def where()

    end

  end
end