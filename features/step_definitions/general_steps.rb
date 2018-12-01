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
rescue Timeout::Error => e
  raise exception
end

Given(/^(pending.*)$/) do |message|
  pending message
end

Given /^everything is indexed$/ do
  Kor::Elastic.index_all
end

When /I debug/ do
  binding.pry
  x = 15
end

When(/^I print the url$/) do
  p current_url
end

When /^I open the inspector$/ do
  page.driver.debug  
end

Given /^everything is processed$/ do
  Delayed::Worker.new.work_off
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
  values.symbolize_keys!

  expect(Kor::Search).to receive(:new).with(
    instance_of(User),
    hash_including(values)
  ).and_call_original
end