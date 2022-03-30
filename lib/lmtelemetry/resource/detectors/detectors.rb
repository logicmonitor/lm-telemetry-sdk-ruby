# frozen_string_literal: true

require 'lmtelemetry/resource/detectors/version'
require 'lmtelemetry/resource/detectors/aws/ec2/ec2'
require 'lmtelemetry/resource/detectors/aws/ecs/ecs'
require 'lmtelemetry/resource/detectors/aws/eks/eks'
require 'lmtelemetry/resource/detectors/aws/lambda/lambda'
require 'lmtelemetry/resource/detectors/gcp/gcp'
require 'lmtelemetry/resource/detectors/autodetector'

module LMTelemetry
  module Resource
    # Detectors contains the resource detectors as well as the AutoDetector
    # that can run all the detectors and return an accumlated resource
    module Detectors
    end
  end
end