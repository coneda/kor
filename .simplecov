if ENV['COVERAGE']
  SimpleCov.start 'rails' do
    use_merging true
    merge_timeout 900
  end
end
