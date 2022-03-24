# frozen_string_literal: true

require 'rubygems'
require 'opentelemetry/sdk'
require 'opentelemetry/exporter/otlp'
require 'opentelemetry/resource/detectors'
require 'bundler/setup'
require 'sinatra'
require 'lmtelemetry/resource/detectors/aws/ecs/ecs'

Bundler.require

# Sample example for testing on AWS ECS
class SampleECS
  include LMTelemetry

  ENV['OTEL_TRACES_EXPORTER'] = 'console'

  LMTelemetry::SDK.configure do |c|
    c.service_name = 'ruby-otlp-ecs'
    c.resource = LMTelemetry::Resource::Detectors::AwsEcs.detect
    c.use_all
  end

  tracer = OpenTelemetry.tracer_provider.tracer('my_app_or_gem', '0.1.0')

  tracer.in_span('foo') do |span|
    # set an attribute
    span.set_attribute('tform', 'osx')
    # add an event
    span.add_event('event in bar')
    # create bar as child of foo
    tracer.in_span('bar') do |child_span|
      # inspect the span
      pp child_span
    end
  end

  sleep 10
end
