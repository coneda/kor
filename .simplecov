if ENV['COVERAGE']
  SimpleCov.start 'rails' do
    use_merging true
    merge_timeout 60 * 60
  end
end
