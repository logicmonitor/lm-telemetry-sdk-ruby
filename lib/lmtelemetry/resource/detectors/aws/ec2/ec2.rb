# frozen_string_literal: true

require 'rubygems'
require 'opentelemetry/sdk'
require 'opentelemetry/exporter/otlp'
require 'rest-client'
require 'json'

module LMTelemetry
  module Resource
    module Detectors
      # AwsEc2 contains detect class method for determining AWS EC2 environment resource attributes
      module AwsEc2
        # AWS Instance Metadata Service Endpoint
        AWS_IMDS_ENDPOINT = 'http://169.254.169.254'
        # AWS Instance Metadata Token header
        AWS_METADATA_TOKEN_HEADER = 'X-aws-ec2-metadata-token'
        # AWS Instance Metadata Identity Document URI
        AWS_INSTANCE_IDENTITY_DOCUMENT_PATH = '/latest/dynamic/instance-identity/document'

        extend self

        # detect class method detects the resource attributes of AWS EC2 environment
        def detect # rubocop:disable Metrics/AbcSize
          resource_attributes = {}
          result = fetch_identity
          return OpenTelemetry::SDK::Resources::Resource.create(resource_attributes) if result.nil?

          resource_attributes[OpenTelemetry::SemanticConventions::Resource::CLOUD_PROVIDER] = 'aws'
          resource_attributes[OpenTelemetry::SemanticConventions::Resource::CLOUD_PLATFORM] = 'aws_ec2'
          resource_attributes[OpenTelemetry::SemanticConventions::Resource::CLOUD_ACCOUNT_ID] = result['accountId']
          resource_attributes[OpenTelemetry::SemanticConventions::Resource::CLOUD_REGION] = result['region']
          resource_attributes[OpenTelemetry::SemanticConventions::Resource::CLOUD_AVAILABILITY_ZONE] = result['availabilityZone']
          resource_attributes[OpenTelemetry::SemanticConventions::Resource::HOST_ID] = result['instanceId']
          resource_attributes[OpenTelemetry::SemanticConventions::Resource::HOST_TYPE] = result['instanceType']
          resource_attributes[OpenTelemetry::SemanticConventions::Resource::HOST_IMAGE_ID] = result['imageId']
          resource_attributes[OpenTelemetry::SemanticConventions::Resource::HOST_NAME] = ENV['HOSTNAME'] || fetch_hostname
          resource_attributes.delete_if { |_key, value| value.nil? || value.empty? }
          OpenTelemetry::SDK::Resources::Resource.create(resource_attributes)
        end

        private

        def fetch_identity
          logger = Logger.new($stdout)
          response = RestClient::Request.execute(
            method: :get,
            url: AWS_IMDS_ENDPOINT + AWS_INSTANCE_IDENTITY_DOCUMENT_PATH,
            headers: { AWS_METADATA_TOKEN_HEADER => ENV['TOKEN'] },
            timeout: 30
          )
        rescue SocketError => e
          logger.error(e.message)
          nil
        rescue RestClient::ExceptionWithResponse => e
          logger.error(e.message)
          nil
        else
          JSON.parse(response.to_str)
        end

        def fetch_hostname
          Socket.gethostname
        rescue StandardError
          ''
        end
      end
    end
  end
end
