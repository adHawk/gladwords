# frozen_string_literal: true

require 'gladwords/struct'

module Gladwords
  class Schema < ROM::Schema
    # AdWords API attributes inferrer which derives types from the AdWords
    # service registry.
    #
    # @api public
    class AttributesInferrer
      SCALAR_TYPE_MAPPING = {
        long: ROM::Types::Int,
        int: ROM::Types::Int,
        string: ROM::Types::String,
        boolean: ROM::Types::Bool,
        double: ROM::Types::Float,
        String_StringMapEntry: ROM::Types::Hash
      }.freeze

      extend Dry::Core::ClassAttributes
      defines :relation_to_type_mappings
      relation_to_type_mappings(
        adwords_user_lists: 'UserList'
      )

      def initalize(options = {})
        @options = options
      end

      def call(schema, gateway)
        type_name = determine_adwords_type_from_relation(schema)
        registry = gateway.service_registry(schema.name.to_sym)
        all_attributes = generate_attributes(type_name, registry)
        attributes = all_attributes.reject { |a| schema.options[:shitlist].include? a.name }
        missing = EMPTY_SET

        [attributes, missing]
      end

      private

      def generate_attributes(type_name, registry)
        type_sig = registry.get_type_signature(type_name)
        aw_field = AdwordsField.new(**type_sig, type: type_name, registry: registry)

        aw_field.fields.map do |field|
          ROM::Attribute.new(field.dry_type).meta(name: field.name)
        end
      end

      def determine_adwords_type_from_relation(schema)
        relation_name = schema.name.to_sym # i.e. :campaigns
        self.class.relation_to_type_mappings.fetch(relation_name) do
          Gladwords::Inflector.classify(relation_name) # i.e. 'Campaign'
        end
      end

      # @api private
      class AdwordsField < Dry::Struct
        constructor_type :schema

        def initialize(**params)
          type_sig = params[:registry].get_type_signature(params[:type])

          if type_sig
            super(with_loaded_type_sig(type_sig, params))
          else
            super(params)
          end
        end

        def with_loaded_type_sig(type_sig, params)
          reg = params[:registry]
          fields = (type_sig[:fields] || []).map do |f|
            AdwordsField.new(**f, registry: reg)
          end
          { **params, **type_sig, registry: reg, fields: fields }
        end

        attribute :name, Dry::Types['string']
        attribute :type, Dry::Types['string']
        attribute :max_occurs, Dry::Types['int'] | ROM::Types.Constant(:unbounded)
        attribute :min_occurs, Dry::Types['int']
        attribute :abstract, Dry::Types['bool'].default(false)
        attribute :registry, Dry::Types::Any
        attribute(:fields, ROM::Types::Array.default { EMPTY_SET })
        attribute(:enumerations, ROM::Types::Array.default { EMPTY_SET })

        def dry_type
          if array?
            meta = base_type.meta
            base = meta[:read] || base_type

            ROM::Types::Array.of(base).default { EMPTY_SET }
          else
            base_type
          end
        end

        private

        def array?
          max_occurs && (max_occurs == :unbounded || max_occurs > 1)
        end

        def abstract?
          abstract
        end

        def scalar?
          SCALAR_TYPE_MAPPING.key?(type.to_sym)
        end

        def unresolvable?
          !scalar? && fields.empty?
        end

        def base_type
          if scalar?
            build_scalar
          elsif abstract?
            ROM::Types::Hash
          elsif unresolvable?
            ROM::Types::Any
          else
            build_new_type
          end
        end

        def build_scalar
          scalar_type = SCALAR_TYPE_MAPPING.fetch(type.to_sym)

          if enumerations.empty?
            scalar_type
          else
            scalar_type.enum(*enumerations)
          end
        end

        def build_new_type
          schema = fields.map { |f| [f.name, f.dry_type] }
          struct_class = build_struct_class

          read_class = ROM::Types.Constructor(struct_class) do |v|
            empty = v == '' || v.nil?
            struct_class.new(empty ? {} : v)
          end

          ROM::Types::Hash.schema(Hash[schema]).meta(read: read_class)
        end

        def build_struct_class
          build_class(name, Gladwords::Struct) do |klass|
            fields.each do |field|
              klass.attribute field.name, field.dry_type.meta(name: field.name)
            end
          end
        end

        def build_class(name, parent, &block)
          class_name = Gladwords::Inflector.camelize(name.to_s.sub(/.*\./, ''))

          Dry::Core::ClassBuilder
            .new(name: class_name, parent: parent, namespace: nil)
            .call(&block)
        end
      end
    end
  end
end
