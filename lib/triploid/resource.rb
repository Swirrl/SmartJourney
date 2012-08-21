# encoding: utf-8
module Triploid

  # module for all domain objects that need to be persisted to the database
  # as resources
  module Resource
    extend ActiveSupport::Concern

    include Triploid::Components

    attr_reader :new_record

    # Instantiate a +Resource+ by it's uri, and some optional attributes
    # The attributes can be a hash or an +RDF::Graph+ of +RDF::Statements+
    #
    # @example Instantiate a new Resource
    #   Person.new('http://ricroberts.com#me')
    #
    # @param [ String, RDF::URI ] uri The uri of the resource.
    # @param [ Hash, RDF::Graph ] attributes Data about this resource, as a Hash or RDF::Graph
    #
    # @return [ Resource ] A new +Resource+
    def initialize(uri, attributes = nil)

    end

    # default comparison is via the uri
    def <=>(other)

    end

    # performs equality checking on the uris
    def ==(other)

    end

    # performs equality checking on the class
    def ===(other)
      other.class == Class ? self.class === other : self == other
    end

    # delegates to ==
    def eql?()
      self == (other)
    end

    def hash
      identity.hash
    end

    # a resource is absolutely identified by it's class and id.
    def identity
      [ self.class, self.id ]
    end

    def to_a
      [ self ]
    end

    module ClassMethods

      # Performs class equality checking.
      def ===(other)
        other.class == Class ? self <= other : other.is_a?(self)
      end

    end

  end

end

# causes any hooks to be fired, if they've been setup on_load of :triploid.
ActiveSupport.run_load_hooks(:triploid, Triploid::Resource)