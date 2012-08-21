# encoding: utf-8
module Triploid

  module Components
    extend ActiveSupport::Concern

    included do
      extend Triploid::Finders
    end

    include ActiveModel::Conversion
    include ActiveModel::MassAssignmentSecurity
    include ActiveModel::Naming
    include ActiveModel::Validations

    # serialisation???
    # use activemodel serialisers??

    include Triploid::Fields
    include Triploid::Attributes

  end

end