# frozen_string_literal: true

require 'k8s-ruby'

# Kubernetes Token Path
K8S_TOKEN_PATH = '/var/run/secrets/kubernetes.io/serviceaccount/token'
# Kubernetes Path where ca.crt is present
K8S_CERT_PATH = '/var/run/secrets/kubernetes.io/serviceaccount/ca.crt'
CONTAINER_ID_LENGTH = 64
# Default path of cgroup file
DEFAULT_CGROUP_PATH = '/proc/self/cgroup'

module LMTelemetry
  module Resource
    module Detectors
      # AwsEks contains detect class method for determining gcp environment resource attributes
      module AwsEks
        extend self
        # detect class method detects the resource attributes of AWS EKS environment
        def detect
          return OpenTelemetry::SDK::Resources::Resource.create(resource_attributes) unless eks?

          # get container ID
          container_id = fetch_container_id
          puts container_id

          # get cluster name
          cluster_name = fetch_cluster_name
          puts cluster_name

          resource_attributes = {}
          resource_attributes[OpenTelemetry::SemanticConventions::Resource::CLOUD_PROVIDER] = 'aws'
          resource_attributes[OpenTelemetry::SemanticConventions::Resource::CLOUD_PLATFORM] = 'aws_eks'
          resource_attributes[OpenTelemetry::SemanticConventions::Resource::CONTAINER_ID] = container_id
          resource_attributes[OpenTelemetry::SemanticConventions::Resource::K8S_CLUSTER_NAME] = cluster_name
          resource_attributes.delete_if { |_key, value| value.nil? || value.empty? }
          OpenTelemetry::SDK::Resources::Resource.create(resource_attributes)
        end

        private

        def eks?
          return false unless file_exists?

          client = K8s::Client.in_cluster_config
          cm = client.api('v1').resource('configmaps', namespace: 'kube-system').get('aws-auth')
        # TODO : Avoid rescue without error class
        rescue StandardError => e
          puts e.message
          false
        else
          !cm['data'].nil?
        end

        def file_exists?
          File.file?(K8S_CERT_PATH) && File.file?(K8S_TOKEN_PATH)
        end

        def fetch_container_id
          read_data = File.read(DEFAULT_CGROUP_PATH).split
          read_data.each do |i|
            return i[i.length - 64..-1] if i.length > 64
          end
        end

        def fetch_cluster_name
          client = K8s::Client.in_cluster_config
          cm = client.api('v1').resource('configmaps', namespace: 'amazon-cloudwatch').get('cluster-info')
          # config = K8s::Config.load_file('~/.kube/config')
          # puts config.list_kube_config_contexts()[1]
          # cluster = K8s::Config.cluster(context.cluster)
          # puts cluster.inspect
        rescue StandardError => e
          puts e.message
          ''
        else
          puts cm.inspect
          cm['cluster.name']
        end
      end
    end
  end
end
