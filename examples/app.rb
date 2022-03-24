# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'
require 'opentelemetry/sdk'
require 'opentelemetry/exporter/otlp'
require 'opentelemetry/resource/detectors'
require 'functions_framework'
require 'base64'
require 'lmtelemetry/resource/detectors/gcp/gcp'

Bundler.require

# Sample example for testing google cloud function
class SampleGCF
  include LMTelemetry

  ENV['OTEL_TRACES_EXPORTER'] = 'console'

  OpenTelemetry::SDK.configure do |c|
    c.service_name = 'ruby-gc-function'
    c.resource = LMTelemetry::Resource::Detectors::GoogleCloudPlatform.detect
    c.use_all
  end

  FunctionsFramework.cloud_event 'hello_pubsub' do |event|
    name = Base64.decode64 event.data['message']['data'] || 'World'
    puts "Hello, #{name}!"
    OpenTelemetry::SDK.configure do |c|
      c.service_name = 'ruby-gc-function'
      c.resource = LMTelemetry::Resource::Detectors::GoogleCloudFunction.detect
      c.use_all
    end
  end
end
