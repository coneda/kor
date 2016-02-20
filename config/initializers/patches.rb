# This shouldn't be necessary but otherwise, assets:precompile always touches
# the db
unless Rails.groups.include?('assets')
  Rails.application.config.session_store :active_record_store, key: '_kor_session'
end