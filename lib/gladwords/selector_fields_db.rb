# frozen_string_literal: true

require 'json'

# Gladwords
module Gladwords
  class UnsupportedVersionError < StandardError; end

  module_function

  def supported_versions
    @supported_versions ||= %i[v201806 v201809]
  end

  def selector_fields_db(version)
    @selector_fields_db ||= {}

    ver = version.to_sym

    unless supported_versions.include?(ver)
      raise UnsupportedVersionError, "#{version} is not supported"
    end

    return @selector_fields_db[ver] if @selector_fields_db[ver]

    db_file = File.join(__dir__, "selector_fields_db/#{version}.json")
    db = JSON.parse(File.read(db_file), symbolize_names: true)
    @selector_fields_db[version] ||= db
  end
end
