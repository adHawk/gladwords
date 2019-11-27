# frozen_string_literal: true

require 'rom/struct'

# For now we override this because adwords does not always return all the
# key-value pairs they say they will. This setting allows for that to happen
# without throwing an error.
#
# For more info: http://dry-rb.org/gems/dry-struct/constructor-types/
if ROM::Struct.respond_to?(:constructor_type) # rubocop:disable Style/GuardClause
  ROM::Struct.constructor_type :schema
else
  raise <<~MSG
    Dry::Struct.constructor_type has been deprecated in v0.5.0, info how to fix is here:
    http://dry-rb.org/gems/dry-struct/constructor-types/
  MSG
end

module Gladwords
  # @api public
  class Struct < ROM::Struct
    constructor_type :schema
  end
end
