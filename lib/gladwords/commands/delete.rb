# frozen_string_literal: true

require 'gladwords/commands/core'

module Gladwords
  module Commands
    # Delete command
    # This command uses the REMOVE operator to delete entities in AdWords
    # @api public
    class Delete < ROM::Commands::Delete
      include Core

      adapter :adwords
      adwords_operator :REMOVE
      operand_mapper ->(entity) { { id: entity[:id] } }

      def execute
        perform_operations(relation.to_a)
      end
    end
  end
end
