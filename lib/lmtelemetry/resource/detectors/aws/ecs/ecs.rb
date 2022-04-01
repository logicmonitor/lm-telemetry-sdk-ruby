# frozen_string_literal: true

require 'rubygems'
require 'opentelemetry/sdk'
require 'opentelemetry/exporter/otlp'
require 'socket'
require 'rest-client'
require 'json'

module LMTelemetry
  module Resource
    module Detectors
      # AwsEcs contains detect class method for determining ecs environment resource attributes
      module AwsEcs
        extend self

        def detect # rubocop:disable Metrics/AbcSize
          resource_attributes = {}
          result = fetch_metadata
          return OpenTelemetry::SDK::Resources::Resource.create(resource_attributes) if result.nil?

          labels = result['Labels']
          image = result['Image'].split(':')
          resource_attributes[OpenTelemetry::SemanticConventions::Resource::CLOUD_PROVIDER] = 'aws'
          resource_attributes[OpenTelemetry::SemanticConventions::Resource::CLOUD_PLATFORM] = 'aws_ecs'
          resource_attributes[OpenTelemetry::SemanticConventions::Resource::CONTAINER_ID] = result['DockerId']
          resource_attributes[OpenTelemetry::SemanticConventions::Resource::CONTAINER_NAME] = labels['com.amazonaws.ecs.container-name']
          resource_attributes[OpenTelemetry::SemanticConventions::Resource::AWS_ECS_TASK_ARN] = labels['com.amazonaws.ecs.task-arn']
          resource_attributes[OpenTelemetry::SemanticConventions::Resource::AWS_ECS_TASK_FAMILY] = labels['com.amazonaws.ecs.task-definition-family']
          resource_attributes[OpenTelemetry::SemanticConventions::Resource::AWS_ECS_TASK_REVISION] = labels['com.amazonaws.ecs.task-definition-version']
          resource_attributes[OpenTelemetry::SemanticConventions::Resource::CONTAINER_IMAGE_NAME] = image[0]
          resource_attributes[OpenTelemetry::SemanticConventions::Resource::CONTAINER_IMAGE_TAG] = image[1]

          resource_attributes.delete_if { |_key, value| value.nil? || value.empty? }
          OpenTelemetry::SDK::Resources::Resource.create(resource_attributes)
        end

        private

        # fetch_metadata calls AWS ECS metadata API
        def fetch_metadata
          logger = Logger.new($stdout)
          metadata_uri = ENV['ECS_CONTAINER_METADATA_URI']
          return nil if metadata_uri.nil?
          response = RestClient.get metadata_uri
        rescue SocketError => e
          logger.error(e.message)
          nil
        rescue RestClient::ExceptionWithResponse => e
          logger.error(e.message)
          nil
        else
          JSON.parse(response.to_str)
        end
      end
    end
  end
end
