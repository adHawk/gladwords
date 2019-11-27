# frozen_string_literal: true

module Gladwords
  module Commands
    # Shared error handler for all AdWords commands
    #
    # @api private
    module ErrorWrapper
      # Handle AdWords errors and re-raise ROM-specific errors
      #
      # @return [Hash, Array<Hash>]
      #
      # @raise AdWords::Error
      #
      # @api public
      def call(*args)
        super
      rescue *ERROR_MAP.keys => e
        raise ERROR_MAP.fetch(e.class, Error), e
      end

      alias [] call
    end
  end
end
