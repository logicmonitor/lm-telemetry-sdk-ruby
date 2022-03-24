# frozen_string_literal: true

require 'rubygems'
require 'opentelemetry/sdk'
require 'opentelemetry/exporter/otlp'
require 'opentelemetry/resource/detectors'
require 'utils/utils'
require 'google-cloud-env'

module LMTelemetry
  module Resource
    module Detectors
      # GCP contains detect method
      module GoogleCloudPlatform
        # extend self

        module_function

        # detect class method for determining gcp environment resource attributes
        def detect
          resource = OpenTelemetry::Resource::Detectors::GoogleCloudPlatform.detect
          obj = Utils.new
          attributes = obj.service_details
          obj.merge_env_res_attributes(resource, attributes)
        end
      end
    end
  end
end
