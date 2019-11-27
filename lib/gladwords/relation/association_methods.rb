# frozen_string_literal: true

require 'gladwords/relation/joined_relation'

module Gladwords
  class Relation < ROM::Relation
    # Instance methods for associations
    #
    # @api public
    module AssociationMethods
      def self.included(klass)
        klass.option :dependant_associations, default: -> { [] }
      end

      # Join with other datasets
      #
      # @param [Array<Dataset>] args A list of dataset to join with
      #
      # @return [Dataset]
      #
      # @api public
      def join(*args)
        targets = nodes(*args)

        JoinedRelation.new(self, targets).relation
      end
    end
  end
end
