# frozen_string_literal: true

require 'gladwords/schema/attributes_inferrer'

module Gladwords
  class Schema < ROM::Schema
    # AdWords API schema inferrer which derives types from the AdWords
    # service registry.
    #
    # @api public
    class Inferrer < ROM::Schema::Inferrer
      attributes_inferrer ->(schema, gateway, _options) do
        # builder = TypeBuilder[gateway.database_type]
        inferrer = AttributesInferrer.new
        inferrer.call(schema, gateway)
      end
    end
  end
end
