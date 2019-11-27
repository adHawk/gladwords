# frozen_string_literal: true

require 'pry'
require 'nokogiri'
require 'json'
require 'open-uri'
require 'gladwords'

def build_row(fields, values)
  hash = Hash[fields.zip(values)]
  hash.delete(:path)

  { **hash, filterable: hash[:filterable] == 'Yes' }
end

adwords_versions = Gladwords.supported_versions.map(&:to_s)

task :generate_selector_fields_db do
  inflector = Gladwords::Inflector
  url = 'https://developers.google.com/adwords/api/docs/appendix/selectorfields'

  adwords_versions.each do |adwords_version|
    puts "-> Generating db for #{adwords_version} from #{url}"

    # rubocop:disable Security/Open
    selectable_fields_docs = open(url)
    # rubocop:enable Security/Open

    page = Nokogiri::HTML(selectable_fields_docs).css('.devsite-article-body')
    tables = page.css('table')

    result = {}

    tables.each do |table|
      service_name_node = table

      service_name_node = service_name_node.previous_sibling until service_name_node.text =~ /\w+Service$/

      unless service_name_node.attributes['id'].value.start_with?(adwords_version)
        next
      end

      service_name = inflector.underscore(service_name_node.text)
      service_name = service_name.gsub('_service', '')
      service_name = inflector.pluralize(service_name)
      service_name = service_name.to_sym

      result[service_name] ||= {}

      fields = table.css('tr > th').map(&:text).map(&:downcase).map(&:to_sym)
      rows = table.css('tr')[1..-1]
      row_fields = rows.map do |row|
        values = row.css('td').map(&:text).map(&:strip)
        build_row(fields, values)
      end

      method = table.previous_sibling.previous_sibling.text.gsub('()', '')
      method = inflector.underscore(method).to_sym
      result[service_name][method] = row_fields
    end

    outfile = "lib/gladwords/selector_fields_db/#{adwords_version}.json"

    File.open(outfile, 'w+') do |file|
      file.write JSON.pretty_generate(result)
    end

    puts "-> Printed to #{outfile}"
  end

  puts '-> Done!'
end
