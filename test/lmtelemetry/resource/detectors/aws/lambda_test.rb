# frozen_string_literal: true

require 'test_helper'
require 'lmtelemetry/resource/detectors/aws/lambda/lambda'

describe LMTelemetry::Resource::Detectors::AwsLambda do
  let(:detector) { LMTelemetry::Resource::Detectors::AwsLambda }

  describe '.detect' do
    let(:detected_resource) { detector.detect(nil) }
    let(:detected_resource_attributes) { detected_resource.attribute_enumerator.to_h }
    let(:expected_resource_attributes) { {} }

    describe 'when in a aws lambda environment' do
      let(:expected_resource_attributes) do
        {
          'cloud.provider' => 'aws',
          'cloud.platform' => 'aws_lambda',
          'cloud.region' => 'us-west-2',
          'faas.name' => 'test-lambda-function',
          'faas.version' => '$TEST',
          'cloud.account.id' => '148849679107'
        }
      end

      it 'returns a resource with aws ec2 attributes' do
        old_function_name = ENV['AWS_LAMBDA_FUNCTION_NAME']
        old_function_version = ENV['AWS_LAMBDA_FUNCTION_VERSION']
        old_region = ENV['AWS_REGION']
        ENV['AWS_LAMBDA_FUNCTION_NAME'] = 'test-lambda-function'
        ENV['AWS_LAMBDA_FUNCTION_VERSION'] = '$TEST'
        ENV['AWS_REGION'] = 'us-west-2'

        Aws.config[:sts] = {
          stub_responses: {
            get_caller_identity: { account: '148849679107' }
          }
        }

        begin
          _(detected_resource).must_be_instance_of(OpenTelemetry::SDK::Resources::Resource)
          _(detected_resource_attributes).must_equal(expected_resource_attributes)
        ensure
          ENV['AWS_LAMBDA_FUNCTION_NAME'] = old_function_name
          ENV['AWS_LAMBDA_FUNCTION_VERSION'] = old_function_version
          ENV['AWS_REGION'] = old_region
        end
      end

      describe 'and a nil resource value is detected' do
        it 'returns a resource without that attribute' do
          old_function_version = ENV['AWS_LAMBDA_FUNCTION_VERSION']
          ENV['AWS_LAMBDA_FUNCTION_VERSION'] = nil
          ENV['AWS_REGION'] = 'us-west-2'
          begin
            _(detected_resource_attributes.key?('faas.version')).must_equal(false)
          ensure
            ENV['AWS_LAMBDA_FUNCTION_VERSION'] = old_function_version
          end
        end
      end

      describe 'and an empty string resource value is detected' do
        it 'returns a resource without that attribute' do
          old_function_version = ENV['AWS_LAMBDA_FUNCTION_VERSION']
          ENV['AWS_LAMBDA_FUNCTION_VERSION'] = ''
          begin
            _(detected_resource_attributes.key?('faas.version')).must_equal(false)
          ensure
            ENV['AWS_LAMBDA_FUNCTION_VERSION'] = old_function_version
          end
        end
      end
    end
  end
end
