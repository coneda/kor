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