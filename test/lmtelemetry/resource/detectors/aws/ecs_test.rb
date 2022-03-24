# frozen_string_literal: true

require 'test_helper'
require 'lmtelemetry/resource/detectors/aws/ecs/ecs'

describe LMTelemetry::Resource::Detectors::AwsEcs do
  let(:detector) { LMTelemetry::Resource::Detectors::AwsEcs }

  describe '.detect' do
    let(:detected_resource) { detector.detect }
    let(:detected_resource_attributes) { detected_resource.attribute_enumerator.to_h }
    let(:expected_resource_attributes) { {} }

    describe 'when an empty string resource value is detected' do
      it 'returns a resource without that attribute' do
        old_metadata_uri = ENV['ECS_CONTAINER_METADATA_URI']
        ENV['ECS_CONTAINER_METADATA_URI'] = 'www.example.com'
        stub_response = { 'DockerId' => '', 'Name' => 'ruby-resource-detect', 'DockerName' => 'ecs-resource-detect-ruby-1-ruby-resource-detect-d6f9f690e68bd6801e00', 'Image' => '148849679107.dkr.ecr.us-west-2.amazonaws.com/ruby-resource:latest', 'ImageID' => 'sha256:0936debe73444900107adaca9c59c4d250adc62177c006a7c8c2d97b09ebcedc', 'Labels' => { 'com.amazonaws.ecs.cluster' => 'Ruby-EC2-Cluster', 'com.amazonaws.ecs.container-name' => 'ruby-resource-detect', 'com.amazonaws.ecs.task-arn' => 'arn:aws:ecs:us-west-2:148849679107:task/Ruby-EC2-Cluster/f084cdf9f44b4304a96f8e9da4561dc6', 'com.amazonaws.ecs.task-definition-family' => 'resource-detect-ruby', 'com.amazonaws.ecs.task-definition-version' => '1' }, 'DesiredStatus' => 'RUNNING', 'KnownStatus' => 'RUNNING', 'Limits' => { 'CPU' => 2, 'Memory' => 0 }, 'CreatedAt' => '2022-02-23T11:35:58.150643568Z', 'StartedAt' => '2022-02-23T11:35:58.92838195Z', 'Type' => 'NORMAL', 'Networks' => [{ 'NetworkMode' => 'awsvpc', 'IPv4Addresses' => ['10.55.15.253'] }] }
        stub_request(:get, ENV['ECS_CONTAINER_METADATA_URI']).to_return(body: stub_response.to_json)
        begin
          _(detected_resource_attributes.key?('container.id')).must_equal(false)
        ensure
          ENV['ECS_CONTAINER_METADATA_URI'] = old_metadata_uri
        end
      end
    end

    describe 'when a resource attribute field does not exist in response' do
      it 'returns a resource without that attribute' do
        old_metadata_uri = ENV['ECS_CONTAINER_METADATA_URI']
        ENV['ECS_CONTAINER_METADATA_URI'] = 'www.example.com'
        stub_response = { 'Name' => 'ruby-resource-detect', 'DockerName' => 'ecs-resource-detect-ruby-1-ruby-resource-detect-d6f9f690e68bd6801e00', 'Image' => '148849679107.dkr.ecr.us-west-2.amazonaws.com/ruby-resource:latest', 'ImageID' => 'sha256:0936debe73444900107adaca9c59c4d250adc62177c006a7c8c2d97b09ebcedc', 'Labels' => { 'com.amazonaws.ecs.cluster' => 'Ruby-EC2-Cluster', 'com.amazonaws.ecs.container-name' => 'ruby-resource-detect', 'com.amazonaws.ecs.task-arn' => 'arn:aws:ecs:us-west-2:148849679107:task/Ruby-EC2-Cluster/f084cdf9f44b4304a96f8e9da4561dc6', 'com.amazonaws.ecs.task-definition-family' => 'resource-detect-ruby', 'com.amazonaws.ecs.task-definition-version' => '1' }, 'DesiredStatus' => 'RUNNING', 'KnownStatus' => 'RUNNING', 'Limits' => { 'CPU' => 2, 'Memory' => 0 }, 'CreatedAt' => '2022-02-23T11:35:58.150643568Z', 'StartedAt' => '2022-02-23T11:35:58.92838195Z', 'Type' => 'NORMAL', 'Networks' => [{ 'NetworkMode' => 'awsvpc', 'IPv4Addresses' => ['10.55.15.253'] }] }
        stub_request(:get, ENV['ECS_CONTAINER_METADATA_URI']).to_return(body: stub_response.to_json)
        begin
          _(detected_resource_attributes.key?('container.id')).must_equal(false)
        ensure
          ENV['ECS_CONTAINER_METADATA_URI'] = old_metadata_uri
        end
      end
    end

    describe 'when there is communication issue with the metadata server ' do
      it 'returns an empty resource' do
        old_metadata_uri = ENV['ECS_CONTAINER_METADATA_URI']
        ENV['ECS_CONTAINER_METADATA_URI'] = 'invalidurl.com'
        begin
          _(detected_resource).must_be_instance_of(OpenTelemetry::SDK::Resources::Resource)
          _(detected_resource_attributes).must_equal(expected_resource_attributes)
        ensure
          ENV['ECS_CONTAINER_METADATA_URI'] = old_metadata_uri
        end
      end
    end

    describe 'when there is service unavailable ' do
      it 'returns an empty resource' do
        old_metadata_uri = ENV['ECS_CONTAINER_METADATA_URI']
        ENV['ECS_CONTAINER_METADATA_URI'] = 'www.example.com'
        stub_request(:get, ENV['ECS_CONTAINER_METADATA_URI']).to_return(status: 503)
        begin
          _(detected_resource).must_be_instance_of(OpenTelemetry::SDK::Resources::Resource)
          _(detected_resource_attributes).must_equal(expected_resource_attributes)
        ensure
          ENV['ECS_CONTAINER_METADATA_URI'] = old_metadata_uri
        end
      end
    end

    describe 'when in a aws lambda environment' do
      let(:expected_resource_attributes) do
        {
          'cloud.provider' => 'aws',
          'cloud.platform' => 'aws_ecs',
          'container.id' => 'cb98cf2d48a8ba2c9732aca6c839932f6224ff878fab25684ea27e62caba9197',
          'container.name' => 'ruby-resource-detect',
          'aws.ecs.task.arn' => 'arn:aws:ecs:us-west-2:148849679107:task/Ruby-EC2-Cluster/f084cdf9f44b4304a96f8e9da4561dc6',
          'aws.ecs.task.family' => 'resource-detect-ruby',
          'aws.ecs.task.revision' => '1',
          'container.image.name' => '148849679107.dkr.ecr.us-west-2.amazonaws.com/ruby-resource',
          'container.image.tag' => 'latest'
        }
      end

      it 'returns a resource with aws ecs attributes' do
        old_metadata_uri = ENV['ECS_CONTAINER_METADATA_URI']
        ENV['ECS_CONTAINER_METADATA_URI'] = 'www.example.com'
        stub_response = { 'DockerId' => 'cb98cf2d48a8ba2c9732aca6c839932f6224ff878fab25684ea27e62caba9197', 'Name' => 'ruby-resource-detect', 'DockerName' => 'ecs-resource-detect-ruby-1-ruby-resource-detect-d6f9f690e68bd6801e00', 'Image' => '148849679107.dkr.ecr.us-west-2.amazonaws.com/ruby-resource:latest', 'ImageID' => 'sha256:0936debe73444900107adaca9c59c4d250adc62177c006a7c8c2d97b09ebcedc', 'Labels' => { 'com.amazonaws.ecs.cluster' => 'Ruby-EC2-Cluster', 'com.amazonaws.ecs.container-name' => 'ruby-resource-detect', 'com.amazonaws.ecs.task-arn' => 'arn:aws:ecs:us-west-2:148849679107:task/Ruby-EC2-Cluster/f084cdf9f44b4304a96f8e9da4561dc6', 'com.amazonaws.ecs.task-definition-family' => 'resource-detect-ruby', 'com.amazonaws.ecs.task-definition-version' => '1' }, 'DesiredStatus' => 'RUNNING', 'KnownStatus' => 'RUNNING', 'Limits' => { 'CPU' => 2, 'Memory' => 0 }, 'CreatedAt' => '2022-02-23T11:35:58.150643568Z', 'StartedAt' => '2022-02-23T11:35:58.92838195Z', 'Type' => 'NORMAL', 'Networks' => [{ 'NetworkMode' => 'awsvpc', 'IPv4Addresses' => ['10.55.15.253'] }] }
        stub_request(:get, ENV['ECS_CONTAINER_METADATA_URI']).to_return(body: stub_response.to_json)
        begin
          _(detected_resource).must_be_instance_of(OpenTelemetry::SDK::Resources::Resource)
          _(detected_resource_attributes).must_equal(expected_resource_attributes)
        ensure
          ENV['ECS_CONTAINER_METADATA_URI'] = old_metadata_uri
        end
      end
    end
  end
end
