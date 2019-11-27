# frozen_string_literal: true

require 'gladwords/commands/error_wrapper'

module Gladwords
  module Commands
    # @api private
    module Core
      extend Dry::Core::ClassAttributes

      # @api private
      module Types
        include Dry::Types.module

        Operation = Hash.schema(
          operator: Coercible::String.enum('ADD', 'SET', 'REMOVE'),
          operand: Hash
        )
      end

      def self.included(klass)
        super

        klass.include ErrorWrapper
        klass.defines :adwords_operator
        klass.defines :operand_mapper
        klass.option :mutator, default: -> { method(:mutate) }
      end

      def execute(tuples)
        perform_operations(tuples)
      end

      def perform_operations(tuples)
        operations = build_operations(tuples)
        raw_result = mutator.call(operations)

        unwrap_result(raw_result)
      end

      private

      def build_operations(tuples)
        ensure_enumerable(tuples).map do |tuple|
          operator(tuple)
        end
      end

      def mutate(operations)
        relation.dataset.mutate(operations)
      end

      def unwrap_result(result)
        result[:value]
      end

      def ensure_enumerable(tuples)
        if tuples.is_a?(Array)
          tuples
        else
          [tuples]
        end
      end

      def operator(operand)
        op = if self.class.operand_mapper
               self.class.operand_mapper.call(operand)
             else
               operand
             end

        Types::Operation[operator: self.class.adwords_operator, operand: op]
      end
    end
  end
end
