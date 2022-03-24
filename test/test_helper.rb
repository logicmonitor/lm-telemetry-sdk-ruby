# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib)
# require 'lmtelemetry/resource/detectors'

require 'simplecov'
SimpleCov.start

require 'minitest/autorun'
# require 'pry'
require 'webmock/minitest'
require 'aws-sdk'
# Aws.stub!
Aws.config.update(stub_responses: true)
WebMock.allow_net_connect!
# WebMock.disable_net_connect!
