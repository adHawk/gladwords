# frozen_string_literal: true

require 'rom/schema'
require 'gladwords/associations'

module Gladwords
  # AdWords API schema
  #
  # @api public
  class Schema < ROM::Schema
    option :shitlist, default: -> { EMPTY_SET }

    # Internal hook used during setup process
    #
    # @see Schema#finalize_associations!
    #
    # @api private
    def finalize_associations!(relations:)
      super do
        associations.map do |definition|
          Gladwords::Associations.const_get(definition.type).new(definition, relations)
        end
      end
    end
  end
end
