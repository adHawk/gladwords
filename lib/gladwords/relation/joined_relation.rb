# frozen_string_literal: true

require 'rom/array_dataset'

module Gladwords
  class Relation < ROM::Relation
    # Helper for bulding out a join relationship
    #
    # @api private
    class JoinedRelation
      extend Dry::Initializer

      param :source
      param :targets

      option :base_class, default: -> { ROM::Relation::Combined }

      def relation
        comb = base_class.new(source, targets)
        targets.each { |rel| build_accessor(rel, comb) }
        comb
      end

      private

      # Will set methods on a relation such as `#ad_groups` such that when
      # they are accessed, a new relation is returned with the proper
      # scoping. By default, the relation will include *all* children, this
      # ensures that only the children which are related by a foreign key
      # (i.e. `campaign_id`) are returned.
      def build_accessor(rel, comb)
        fk = rel.meta[:keys].fetch(:id)
        node = build_pristine_relation(
          rel.relation,
          dependant_associations: [[fk, source]],
          auto_struct: true,
          auto_map: true
        )
        comb.define_singleton_method(node.name.to_sym) { node }
      end

      def build_pristine_relation(relation, **params)
        opts = relation.options.dup
        opts.delete(:mappers)
        opts.delete(:__registry__)
        opts.delete(:meta)

        relation.class.new(relation.dataset, **opts, **params)
      end
    end
  end
end
