# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gladwords/version'

Gem::Specification.new do |spec|
  spec.name          = 'gladwords'
  spec.version       = Gladwords::VERSION.dup
  spec.authors       = ['Ian Ker-Seymer', 'Patrick Sparrow']
  spec.email         = ['ian@tryadhawk.com', 'patrick@tryadhawk.com']
  spec.summary       = 'AdWords support for ROM.rb'
  spec.description   = spec.summary
  spec.homepage      = 'https://github.com/adHawk/gladwords'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'google-adwords-api'
  spec.add_runtime_dependency 'rom', '~> 4.2.0'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake', '~> 10.0'
end
