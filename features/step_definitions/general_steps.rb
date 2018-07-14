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