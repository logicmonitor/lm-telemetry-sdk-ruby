# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lmtelemetry/resource/detectors/version'

Gem::Specification.new do |spec|
  spec.name        = 'lm-telemetry-sdk-ruby'
  spec.version     = LMTelemetry::Resource::Detectors::VERSION
  spec.authors     = ['lmoteldev']
  spec.email       = ['lmoteldev@logicmonitor.com']

  spec.summary     = 'Resource detection helpers for LMTelemetry'
  spec.description = 'Resource detection helpers for LMTelemetry'
  spec.license     = 'MIT'

  spec.files = ::Dir.glob('lib/**/*.rb') +
               ::Dir.glob('*.md') +
               ['LICENSE', '.yardopts']
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 2.5.0'

  spec.add_dependency 'google-cloud-env'
  spec.add_dependency 'opentelemetry-sdk'
  spec.add_dependency 'rest-client'

  spec.add_development_dependency 'bundler', '>= 1.17'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rubocop', '~> 0.73.0'
  spec.add_development_dependency 'simplecov', '~> 0.17'
  spec.add_development_dependency 'yard', '~> 0.9'
  spec.add_development_dependency 'yard-doctest', '~> 0.1.6'

  # if spec.respond_to?(:metadata)
  #   spec.metadata['changelog_uri'] = 'TODO: Put your gem's CHANGELOG.md URL here.'
  #   spec.metadata['source_code_uri'] = 'TODO: Put your gem's public repo URL here.'
  #   spec.metadata['documentation_uri'] = 'TODO: Put your gem's Dcoumentation URL here.'
  # end
end
