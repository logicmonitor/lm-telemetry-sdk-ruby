# frozen_string_literal: true

require 'rubygems'
require 'opentelemetry/sdk'
require 'opentelemetry/exporter/otlp'
require 'aws-sdk-core'

module LMTelemetry
  module Resource
    module Detectors
      # AwsLambda contains detect method to detect lambda resource attributes
      module AwsLambda
        extend self

        def detect(context = nil) # rubocop:disable Metrics/AbcSize
          function_name = ENV['AWS_LAMBDA_FUNCTION_NAME']
          function_version = ENV['AWS_LAMBDA_FUNCTION_VERSION']
          region = ENV['AWS_REGION']

          resource_attributes = {}
          resource_attributes[OpenTelemetry::SemanticConventions::Resource::CLOUD_PROVIDER] = 'aws'
          resource_attributes[OpenTelemetry::SemanticConventions::Resource::CLOUD_PLATFORM] = 'aws_lambda'
          resource_attributes[OpenTelemetry::SemanticConventions::Resource::FAAS_NAME] = function_name
          resource_attributes[OpenTelemetry::SemanticConventions::Resource::FAAS_VERSION] = function_version
          resource_attributes[OpenTelemetry::SemanticConventions::Resource::CLOUD_REGION] = region

          # context contains arn
          if context.nil?
            unless region.nil?
              client = Aws::STS::Client.new
              resp = client.get_caller_identity({})
              resource_attributes[OpenTelemetry::SemanticConventions::Resource::CLOUD_ACCOUNT_ID] = resp.account
            end
          else
            resource_attributes[OpenTelemetry::SemanticConventions::Resource::FAAS_ID] = context.invoked_function_arn
          end
          resource_attributes.delete_if { |_key, value| value.nil? || value.empty? }
          OpenTelemetry::SDK::Resources::Resource.create(resource_attributes)
        end
      end
    end
  end
end
