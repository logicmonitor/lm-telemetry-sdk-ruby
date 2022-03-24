# frozen_string_literal: true

require 'rubygems'
require 'opentelemetry/sdk'
require 'opentelemetry/exporter/otlp'
require 'opentelemetry/resource/detectors'
require 'bundler/setup'
require 'sinatra'
require 'lmtelemetry/resource/detectors/gcp/gcp'

Bundler.require

# sample example to test GCE
# same can be used for AWS EC2 by changing the imports and module to Ec2
class SampleGCP
  include LMTelemetry

  ENV['OTEL_TRACES_EXPORTER'] = 'console'

  OpenTelemetry::SDK.configure do |c|
    c.service_name = 'ruby-otlp'
    c.resource = LMTelemetry::Resource::Detectors::GoogleCloudPlatform.detect
    c.use_all
  end

  get '/frank-says' do
    'Put this in your pipe & smoke it!'
  end
  get '/hello' do
    'sintara says hello!'
  end
  get '/' do
    'existing paths: /hello, /frank-says, /logicmonitor!'
  end
  get '/logicmonitor' do
    'Hello from Logicmonitor!'
  end
end
