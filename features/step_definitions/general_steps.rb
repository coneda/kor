# we need this to simulate the old wait_until behavior to code matches that
# don't exist, e.g. somethine like have_current_url
def capybara_wait
  exception = nil
  Timeout.timeout(Capybara.default_max_wait_time) do
    loop do
      begin
        yield
        exception = nil
        break
      rescue RSpec::Expectations::ExpectationNotMetError => e
        exception = e
        sleep 0.2
      end
    end
  end
rescue Timeout::Error
  raise exception
end

Given(/^(pending.*)$/) do |message|
  pending message
end

When /I debug/ do
  binding.pry
end

Given 'the search api expects to receive the params' do |table|
  values = table.raw.to_h
  values['dataset'] = {}
  values.each do |k, v|
    if m = k.match(/^dataset_(.+)$/)
      values['dataset'][m[1]] = v
      values.delete k
    end
  end
  if values['kind_id']
    values['kind_id'] = values['kind_id'].split(',').map { |e| e.to_i }
  end
  if values['except_kind_id']
    values['except_kind_id'] = values['except_kind_id'].split(',').map { |e| e.to_i }
  end
  if values['tags']
    values['tags'] = values['tags'].split(',')
  end
  values.symbolize_keys!

  expect(Kor::Search).to receive(:new).with(
    instance_of(User),
    hash_including(values)
  ).and_call_original
end
