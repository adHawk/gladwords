# frozen_string_literal: true

require 'codacy-coverage'
Codacy::Reporter.start

require 'gladwords'
require 'adwords_api'
require 'pry'

root = Pathname(__FILE__).dirname

Dir[root.join('{shared,support}/**/*.rb')].each { |f| require f }
Dir[root.join('shared/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  config.include AdwordsHelpers

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.disable_monkey_patching!
  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = 'tmp/examples.txt'
  config.order = :random
  config.formatter = :documentation
  Kernel.srand config.seed
end
