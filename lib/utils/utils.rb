# frozen_string_literal: true

# Utils class merges custom resource attributes
class Utils
  def service_details
    res_attr = ENV['OTEL_RESOURCE_ATTRIBUTES'] || ''
    attributes = {}
    return attributes if res_attr.empty?

    arr = res_attr.split(',')
    arr.each do |s|
      v = s.split('=')
      attributes[v[0]] = v[1]
    end
    attributes
  end

  def merge_env_res_attributes(resource, attribute)
    return resource if attribute.nil?

    new_res = OpenTelemetry::SDK::Resources::Resource.create(attribute)
    resource.merge(new_res)
  end
end
