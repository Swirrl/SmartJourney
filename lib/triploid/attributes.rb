module Triploid

  module Attributes

    attr_reader :attributes

    # Read a value from the resource attributes. If the value does not exist
    # it will return nil.
    #
    # @example Read an attribute.
    #   person.read_attribute(:title)
    #
    # @example Read an attribute (alternate syntax.)
    #   person[:title]
    #
    # @param [ String, Symbol ] name The name of the attribute to get.
    #
    # @return [ Object ] The value of the attribute.
    def read_attribute(name)
      attributes[name.to_s]
    end
    alias :[] :read_attribute

    # Write a single attribute to the resource attribute hash.
    #
    # @example Write the attribute.
    #   person.write_attribute(:title, "Mr.")
    #
    # @example Write the attribute (alternate syntax.)
    #   person[:title] = "Mr."
    #
    # @param [ String, Symbol ] name The name of the attribute to update.
    # @param [ Object ] value The value to set for the attribute.
    #
    # TODO: do type casting and trigger callbacks?
    def write_attribute(name, value)
      attributes[name.to_s] = value
      value
    end
    alias :[]= :write_attribute

  end

end