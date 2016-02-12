module Kernel
  def ArgumentArray(value)
    value.is_a?(Array) ? value : [value]
  end
end

# This doesn't belong here, but otherwise, assets:precompile always touches the
# db
unless Rails.groups.include?('assets')
  require 'delayed_job_active_record'
  Rails.application.config.session_store :active_record_store, key: '_kor_session'
end