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
  values.delete 'name'

  dataset = {}
  values.each do |k, v|
    if m = k.match(/^dataset_(.+)$/)
      dataset[m[1]] = v
      values.delete k
    end
  end
  values['dataset'] = dataset unless dataset.empty?

  if values['kind_id']
    values['kind_id'] = values['kind_id'].split(',').map{ |e| e.to_i }
  end
  if values['except_kind_id']
    values['except_kind_id'] = values['except_kind_id'].split(',').map{ |e| e.to_i }
  end
  if values['tags']
    values['tags'] = values['tags'].split(',')
  end

  ['file_size', 'larger_than', 'smaller_than'].each do |k|
    values[k] = values[k].to_i if values[k]
  end
  values.symbolize_keys!

  expect(Kor::Search).to receive(:new).with(
    instance_of(User),
    hash_including(values)
  ).and_call_original
end

Then("there should be {string} outgoing email") do |amount|
  actual = ActionMailer::Base.deliveries.size
  expect(actual).to eq(amount.to_i)
end

When("I click the download link in mail {string}") do |index|
  mail = ActionMailer::Base.deliveries[index.to_i - 1]
  link = mail.body.to_s.scan(%r{http://[^/]+/downloads[^\s]+}).first

  visit link
end
