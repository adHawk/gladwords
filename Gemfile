# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

group :test do
  gem 'codacy-coverage', require: false
  gem 'google-adwords-api', github: 'ianks/google-api-ads-ruby', branch: 'enums-generated'
  gem 'pry-byebug'
  gem 'rspec'
end

group :development, :test do
  gem 'rubocop'
  gem 'rubocop-performance'
end

group :local do
  gem 'solargraph'
end
