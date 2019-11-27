# frozen_string_literal: true

require 'gladwords/commands/core'

module Gladwords
  module Commands
    # Create command
    # This command uses the ADD operator to create entities in AdWords
    # @api public
    class Create < ROM::Commands::Create
      include Core

      adapter :adwords

      adwords_operator :ADD
    end
  end
end
