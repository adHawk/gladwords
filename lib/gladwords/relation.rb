# frozen_string_literal: true

require 'rom/relation'
require 'gladwords/schema'
require 'gladwords/schema/inferrer'
require 'gladwords/schema/dsl'
require 'gladwords/relation/association_methods'

module Gladwords
  # AdWords API relation
  #
  # @api public
  class Relation < ROM::Relation
    include Gladwords
    include AssociationMethods

    class FieldResolutionError < StandardError; end
    class InvalidRequestMethodError < StandardError; end

    adapter :adwords

    defines :action
    action :get

    defines :default_select_fields
    default_select_fields -> { default_fields }

    option :method, default: -> { self.class.action }
    option :selector, default: -> { {} }
    option :primary_key, default: -> { schema.primary_key_name }

    schema_class Gladwords::Schema
    schema_dsl Gladwords::Schema::DSL
    schema_inferrer Gladwords::Schema::Inferrer.new.freeze

    struct_namespace Gladwords::Struct

    def primary_key
      schema.canonical.primary_key
    end

    def by_pk(pkey)
      if primary_key.empty?
        raise MissingPrimaryKeyError, "Missing primary key for :\#{schema.name}"
      end

      # This is most likely wrong in edge cases.
      # https://github.com/rom-rb/rom-sql/blob/dea2fb877a6f5e8a60df3f0eb0b54c499443b0b2/lib/rom/sql/relation.rb#L63
      where(schema.canonical.primary_key.first.name => pkey).limit(1)
    end

    def each
      return to_enum unless block_given?

      materialized = view

      entries = materialized.is_a?(Array) ? materialized : materialized.fetch(:entries, [])

      if auto_map?
        schema_mapped = entries.map { |tuple| output_schema[tuple] }
        mapped = mapper.call(schema_mapped)
        mapped.each { |struct| yield(struct) }
      else
        entries.each { |tuple| yield(output_schema[tuple]) }
      end
    end

    # Pluck fields from a relation
    #
    # @example
    #   users.pluck(:id).to_a
    #   # [1, 2, 3]
    #
    # @param [Symbol] key An optional name of the key for extracting values
    #                     from tuples
    #
    # @api public
    def pluck(name)
      select(name) >> ->(ents) { ents.map(&name) }
    end

    # Specify a method to use when accessing the SOAP interface
    #
    # @example
    #   customers.request(:get_customers).to_a
    #
    # @param [Symbol] method_name Method name on SOAP interface
    #
    # @api public
    def request(method_name)
      unless dataset.send(:get_service_registry).get_method_signature(method_name)
        raise InvalidRequestMethodError, "Dataset does not respond to ##{method_name}"
      end

      with(method: method_name)
    end

    def select(*fields)
      mapped_fields = fields.map(&:to_s).map { |t| camelcase(t) }
      old_fields = options.dig(:selector, :fields) || []
      new_fields = Set[*old_fields, *mapped_fields].to_a
      selected = with_selector(options[:selector].merge(fields: new_fields))
      selected.with(schema: schema.project(*fields))
    end

    def where(**attrs)
      with_selector(options[:selector].deep_merge(predicates: where_predicates(attrs)))
    end

    def where_predicates(**attrs)
      old_predicates = options.dig(:selector, :predicates) || EMPTY_SET

      new_predicates = attrs.map do |name, value|
        { field: camelcase(name),
          operator: 'IN',
          values: [value].flatten }
      end

      Set[*old_predicates, *new_predicates].to_a
    end

    def total_count
      view[:total_num_entries]
    end

    def count
      limit(0).send(:view)[:total_num_entries]
    end

    def offset(amt)
      paging = { paging: { start_index: amt } }
      with_selector(paging)
    end

    def limit(amt)
      paging = { paging: { number_results: amt } }
      with_selector(paging)
    end

    private

    def with_selector(**attrs)
      with(selector: options[:selector].deep_merge(attrs))
    end

    def view
      return @view if @view

      resolve_dependant_associations

      @view ||= dataset.public_send(options.fetch(:method, self.class.action), compiled_selector)
    end

    def resolve_dependant_associations
      deps = options[:dependant_associations]
      depedendant_predicates = deps.map do |fk, relation|
        [fk, relation.pluck(:id).call]
      end

      new_predicates = where_predicates(Hash[depedendant_predicates])
      options[:selector][:predicates] = new_predicates
    end

    def camelcase(str)
      inflector = Gladwords::Inflector
      inflector.camelize(str)
    end

    def default_fields
      fetch_db_fields.map { |entry| camelcase(entry[:field]) }.uniq
    end
    memoize :default_fields

    def compiled_selector
      fields = if selector.fetch(:fields, []).empty?
                 instance_exec(&self.class.default_select_fields)
               else
                 selector[:fields]
               end
      { fields: fields, **options[:selector] }
    end

    def fetch_db_fields
      version = options.fetch(:dataset).version.to_sym
      db = Gladwords.selector_fields_db(version)
      db_fields = db.dig(name.to_sym, options[:method].to_sym)

      return db_fields unless db_fields.nil?

      raise FieldResolutionError,
            "Could not mind fields for: #{name} -> #{options[:method]}.\n" \
            'Please ensure that relation name and method are correct by ' \
            'inspecting `Gladwords.selector_fields_db(:#{version})` and ensure ' \
            'the relation name and method exist.'
    end
  end
end
