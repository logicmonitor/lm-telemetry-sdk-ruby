# lm-telemetry-sdk-ruby, a ruby sdk for OpenTelemetry by LogicMonitor

_NOTE: This is in private beta._

### LM-telemetry-sdk-ruby

1. Aims to minimize adding initialization code for opentelemetry tracing, assumes default values
2. It has implementation for cloud specific resource detectors

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'lmtelemetry-sdk-ruby'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install lmtelemetry-sdk-ruby


### Usage

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

#### Resource detection for cloud environments

##### AWS 

###### EC2
```
    OpenTelemetry::SDK.configure do |c|
      c.service_name = 'ruby-ec2-function'
      c.resource = LMTelemetry::Resource::Detectors::AwsEc2.detect
      c.use_all
    end
```
###### ECS
```
    OpenTelemetry::SDK.configure do |c|
      c.service_name = 'ruby-ecs-function'
      c.resource = LMTelemetry::Resource::Detectors::AwsEcs.detect
      c.use_all
    end
```
###### EKS
```
    OpenTelemetry::SDK.configure do |c|
      c.service_name = 'ruby-eks-function'
      c.resource = LMTelemetry::Resource::Detectors::AwsEks.detect
      c.use_all
    end
```
###### Lambda
```
    OpenTelemetry::SDK.configure do |c|
      c.service_name = 'ruby-lambda-function'
      c.resource = LMTelemetry::Resource::Detectors::AwsLambda.detect(context)
      c.use_all
    end
```

##### GCP

```  
OpenTelemetry::SDK.configure do |c|
    c.service_name = 'ruby-gc-function'
    c.resource = LMTelemetry::Resource::Detectors::GoogleCloudPlatform.detect
    c.use_all
  end
```


