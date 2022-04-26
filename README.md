# lmtelemetry-sdk-ruby, a ruby sdk for resource detection by LogicMonitor

_NOTE: This is in private beta._

### lmtelemetry-sdk-ruby

1. Aims to minimize adding initialization code for opentelemetry tracing, assumes default values
2. It has implementation for cloud specific resource detectors

## Installation

If you use Bundler, include 'lm-telemetry-sdk-ruby' to your application's Gemfile:

```ruby
gem 'lm-telemetry-sdk-ruby'
```

And execute:

    $ bundle install

OR install the gem as:

    $ gem install lm-telemetry-sdk-ruby


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Usage

### Resource detection for cloud environments

#### ***# For a specific platform***

##### Amazon Web Services (AWS) 

###### EC2
```
    require 'lmtelemetry/resource/detectors/aws/ec2/ec2'
    ...
    OpenTelemetry::SDK.configure do |c|
      c.service_name = 'ruby-ec2-function'
      c.resource = LMTelemetry::Resource::Detectors::AwsEc2.detect
      c.use_all
    end
```
##### List of the detected attributes

Attributes | Description |
---        | ---         |
cloud.provider | Name of the cloud provider
cloud.platform | The cloud platform in use
cloud.account.id | The cloud account ID the resource is assigned to
cloud.region | The geographical region the resource is running
cloud.availability_zone | Represents the zone where the resource is running
host.id | The instance_id assigned by the cloud provider
host.type | Type of host. This must be the machine type
host.image.id | VM image ID
host.name | Name of the host


###### ECS
```
    require 'lmtelemetry/resource/detectors/aws/ecs/ecs'
    ...
    OpenTelemetry::SDK.configure do |c|
      c.service_name = 'ruby-ecs-function'
      c.resource = LMTelemetry::Resource::Detectors::AwsEcs.detect
      c.use_all
    end
```
##### List of the detected attributes

Attributes | Description |
---        | ---         |
cloud.provider | Name of the cloud provider
cloud.platform | The cloud platform in use
container.id | Container ID
container.name | Container name used by container runtime
container.image.name | Name of the image the container was built on
container.image.tag | Container image tag
aws.ecs.task.arn | The ARN of an ECS task definition
aws.ecs.task.family | The task definition family this task definition is a member of
aws.ecs.task.revision | The revision for this task definition


###### EKS
```
    require 'lmtelemetry/resource/detectors/aws/eks/eks'
    ...
    OpenTelemetry::SDK.configure do |c|
      c.service_name = 'ruby-eks-function'
      c.resource = LMTelemetry::Resource::Detectors::AwsEks.detect
      c.use_all
    end
```
##### List of the detected attributes

Attributes | Description |
---        | ---         |
cloud.provider | Name of the cloud provider
cloud.platform | The cloud platform in use
container.id | Container ID
k8s.cluster.name | The name of the cluster


###### Lambda
```
    require 'lmtelemetry/resource/detectors/aws/lambda/lambda'
    ...
    OpenTelemetry::SDK.configure do |c|
      c.service_name = 'ruby-lambda-function'
      c.resource = LMTelemetry::Resource::Detectors::AwsLambda.detect(context)
      c.use_all
    end
```
##### List of the detected attributes

Attributes | Description |
---        | ---         |
cloud.provider | Name of the cloud provider
cloud.platform | The cloud platform in use
cloud.region | The geographical region wher Lambda is running
faas.name | The name of the function
faas.version | The immutable version of the function being executed


##### Google Cloud Platform (GCP)

It supports Google Compute Engine(GCE), Google Kubernetes Engine(GKE) and Google Cloud Functions(GCF).

```  
    require 'lmtelemetry/resource/detectors/gcp/gcp'
    ...
    OpenTelemetry::SDK.configure do |c|
      c.service_name = 'ruby-gc-function'
      c.resource = LMTelemetry::Resource::Detectors::GoogleCloudPlatform.detect
      c.use_all
    end
```
##### **List of the detected attributes**
##### GCE

Attributes | Description |
---        | ---         |
cloud.provider | Name of the cloud provider
cloud.account.id | The cloud account ID the resource is assigned to
cloud.region | The geographical region the resource is running
cloud.availability_zone | Represents the zone where the resource is running
host.id | The instance_id assigned by the cloud provider
host.name | Name of the host

##### GKE

Attributes | Description |
---        | ---         |
k8s.cluster.name | The name of the cluster
k8s.container.name | The name of the Container from Pod specification, must be unique within a Pod. 
k8s.pod.name | The name of the Pod
k8s.node.name | The name of the Node
k8s.namespace.name | The name of the namespace that the pod is running in

##### GCF

Attributes | Description |
---        | ---         |
cloud.provider | Name of the cloud provider
cloud.account.id | The cloud account ID the resource is assigned to
cloud.region | The geographical region wher GCF is running
cloud.availability_zone | Represents the zone where the resource is running
faas.name | The name of the function
faas.version | The immutable version of the function being executed

#### ***# If you would like to run all the detectors available***

```  
    require 'lmtelemetry/resource/detectors'
    ...
    OpenTelemetry::SDK.configure do |c|
      c.service_name = 'ruby-gc-function'
      c.resource = LMTelemetry::Resource::Detectors::Autodetector.detect
      c.use_all
    end
```