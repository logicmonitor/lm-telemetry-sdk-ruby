# frozen_string_literal: true

require 'lmtelemetry/resource/detectors/aws/ec2/ec2'
require 'lmtelemetry/resource/detectors/aws/ecs/ecs'
require 'lmtelemetry/resource/detectors/aws/eks/eks'
require 'lmtelemetry/resource/detectors/aws/lambda/lambda'
require 'lmtelemetry/resource/detectors/gcp/gcp'

LM_RESOURCE_DETECTOR = 'LM_RESOURCE_DETECTOR'
DETECTORS = [
  LMTelemetry::Resource::Detectors::GoogleCloudPlatform,
  LMTelemetry::Resource::Detectors::AwsEc2,
  LMTelemetry::Resource::Detectors::AwsEcs,
  LMTelemetry::Resource::Detectors::AwsEks,
  LMTelemetry::Resource::Detectors::AwsLambda
].freeze

module LMTelemetry
  module Resource
    module Detectors
      # AutoDetector contains detect class method for running all detectors
      module AutoDetector
        extend self
        def detect
          resource_detector = ENV[LM_RESOURCE_DETECTOR]
          case resource_detector
          when 'AWS_EC2'
            LMTelemetry::Resource::Detectors::AwsEc2.detect
          when 'AWS_ECS'
            LMTelemetry::Resource::Detectors::AwsEcs.detect
          when 'AWS_EKS'
            LMTelemetry::Resource::Detectors::AwsEks.detect
          when 'AWS_LAMBDA'
            LMTelemetry::Resource::Detectors::AwsLambda.detect
          when 'GCP'
            LMTelemetry::Resource::Detectors::GoogleCloudPlatform.detect
          else
            DETECTORS.map(&:detect).reduce(:merge)
          end
        end
      end
    end
  end
end
