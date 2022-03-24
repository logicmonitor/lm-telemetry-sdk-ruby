# frozen_string_literal: true

require 'test_helper'
require 'lmtelemetry/resource/detectors/aws/ec2/ec2'

describe LMTelemetry::Resource::Detectors::AwsEc2 do
  let(:detector) { LMTelemetry::Resource::Detectors::AwsEc2 }

  describe '.detect' do
    let(:detected_resource) { detector.detect }
    let(:detected_resource_attributes) { detected_resource.attribute_enumerator.to_h }
    let(:expected_resource_attributes) { {} }

    describe 'when an empty string resource value is detected' do
      it 'returns a resource without that attribute' do
        stub_response = {
          'accountId' => '',
          'architecture' => 'x86_64',
          'availabilityZone' => 'us-west-2b',
          'imageId' => 'ami-09889d8d54f9e0a0e',
          'instanceId' => 'i-00d26ccb664b2a90e',
          'instanceType' => 't2.micro',
          'pendingTime' => '2022-03-11T13:11:09Z',
          'privateIp' => '10.55.15.102',
          'region' => 'us-west-2',
          'version' => '2017-09-30'
        }
        stub_request(:get, 'http://169.254.169.254/latest/dynamic/instance-identity/document')
          .with(headers: { 'X-Aws-Ec2-Metadata-Token' => '' })
          .to_return(status: 200, body: stub_response.to_json)
        _(detected_resource_attributes.key?('cloud.account.id')).must_equal(false)
      end
    end

    describe 'when there is communication issue with the metadata server' do
      it 'returns an empty resource' do
        stub_request(:get, 'http://169.254.169.254/latest/dynamic/instance-identity/document')
          .with(headers: { 'X-Aws-Ec2-Metadata-Token' => '' })
          .to_return(status: 500)
        begin
          _(detected_resource).must_be_instance_of(OpenTelemetry::SDK::Resources::Resource)
          _(detected_resource_attributes).must_equal(expected_resource_attributes)
        end
      end
    end

    describe 'when a resource attribute field does not exist in response' do
      it 'returns a resource without that attribute' do
        stub_response = {
          'architecture' => 'x86_64',
          'availabilityZone' => 'us-west-2b',
          'imageId' => 'ami-09889d8d54f9e0a0e',
          'instanceId' => 'i-00d26ccb664b2a90e',
          'instanceType' => 't2.micro',
          'pendingTime' => '2022-03-11T13:11:09Z',
          'privateIp' => '10.55.15.102',
          'region' => 'us-west-2',
          'version' => '2017-09-30'
        }
        stub_request(:get, 'http://169.254.169.254/latest/dynamic/instance-identity/document')
          .with(headers: { 'X-Aws-Ec2-Metadata-Token' => '' })
          .to_return(status: 200, body: stub_response.to_json)
        _(detected_resource_attributes.key?('cloud.account.id')).must_equal(false)
      end
    end

    describe 'when in a aws ec2 environment' do
      let(:expected_resource_attributes) do
        {
          'cloud.provider' => 'aws',
          'cloud.platform' => 'aws_ec2',
          'cloud.account.id' => '148849679107',
          'cloud.region' => 'us-west-2',
          'cloud.availability_zone' => 'us-west-2b',
          'host.id' => 'i-00d26ccb664b2a90e',
          'host.type' => 't2.micro',
          'host.image.id' => 'ami-09889d8d54f9e0a0e',
          'host.name' => 'ip-10-55-15-102'
        }
      end

      it 'returns a resource with aws ec2 attributes' do
        stub_response = {
          'accountId' => '148849679107',
          'architecture' => 'x86_64',
          'availabilityZone' => 'us-west-2b',
          'imageId' => 'ami-09889d8d54f9e0a0e',
          'instanceId' => 'i-00d26ccb664b2a90e',
          'instanceType' => 't2.micro',
          'privateIp' => '10.55.15.102',
          'region' => 'us-west-2',
          'version' => '2017-09-30'
        }
        ip_dup = stub_response['privateIp'].dup
        new_ip = ip_dup.gsub('.', '-')
        old_hostname = ENV['HOSTNAME']
        ENV['HOSTNAME'] = "ip-#{new_ip}"
        stub_request(:get, 'http://169.254.169.254/latest/dynamic/instance-identity/document')
          .with(headers: { 'X-Aws-Ec2-Metadata-Token' => '' })
          .to_return(status: 200, body: stub_response.to_json)
        begin
          _(detected_resource).must_be_instance_of(OpenTelemetry::SDK::Resources::Resource)
          _(detected_resource_attributes).must_equal(expected_resource_attributes)
        ensure
          ENV['HOSTNAME'] = old_hostname
        end
      end
    end
  end
end
