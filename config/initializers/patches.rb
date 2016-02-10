module Kernel
  def ArgumentArray(value)
    value.is_a?(Array) ? value : [value]
  end
end

unless Rails.groups.include?(:assets)
  require 'delayed_job_active_record'
end