require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "selectors"))

module WithinHelpers
  def with_scope(locator)
    locator ? within(*selector_for(locator)) { yield } : yield
  end
end
World(WithinHelpers)

When /^(.*) within (.+)$/ do |step, parent|
  with_scope(parent) { step step }
end

When /^(.*) within ([^:]+):$/ do |step, parent, table_or_string|
  with_scope(parent) { step "#{step}:", table_or_string }
end

Given /^(?:|I )am on (.+)$/ do |page_name|
  visit path_to(page_name)
end

When /^(?:|I )go to (.+)$/ do |page_name|
  visit path_to(page_name)
end

When /^(?:|I )press "([^"]*)"$/ do |button|
  click_button(button)
end

When /^(?:|I )follow "([^"]*)"$/ do |locator|
  click_link(locator)
end

When /^(?:|I )fill in "([^"]*)" with( quoted)? "([^"]*)"$/ do |field, quoted, value|
  value = "\"#{value}\"" if quoted == ' quoted'
  fill_in(field, :with => value)
end

When /^(?:|I )fill in the following:$/ do |fields|
  fields.rows_hash.each do |name, value|
    step %{I fill in "#{name}" with "#{value}"}
  end
end

When /^(?:|I )select "([^"]*)" from "([^"]*)"$/ do |value, field|
  select(value, :from => field)
end

When /^(?:|I )check "([^"]*)"$/ do |field|
  check(field)
end

When /^(?:|I )uncheck "([^"]*)"$/ do |field|
  uncheck(field)
end

When /^(?:|I )choose "([^"]*)"$/ do |field|
  choose(field)
end

When /^(?:|I )attach the file "([^"]*)" to "([^"]*)"$/ do |path, field|
  attach_file(field, File.expand_path(path))
end

Then /^(?:|I )should see "([^"]*)"$/ do |text|
  if page.respond_to? :should
    page.should have_content(text)
  else
    assert page.has_content?(text)
  end
end

Then /^(?:|I )should see \/([^\/]*)\/$/ do |regexp|
  regexp = Regexp.new(regexp)

  if page.respond_to? :should
    page.should have_xpath('//*', :text => regexp)
  else
    assert page.has_xpath?('//*', :text => regexp)
  end
end

Then /^(?:|I )should not see "([^\"]*)"$/ do |text|
  if page.respond_to? :should
    page.should have_no_content(text)
  else
    assert page.has_no_content?(text)
  end
end

Then /^(?:|I )should be on (.+)$/ do |page_name|
  expected_uri = URI.parse(path_to(page_name))
  uri = URI.parse(current_url)

  expect(uri.path).to eq(expected_uri.path)

  if expected_uri.fragment
    expect(uri.fragment).to eq(expected_uri.fragment)
  end
end

Then /^I should( not)? see element "(.*?)" with text "(.*?)"$/ do |negative, locator, text|
  if negative == " not"
    page.should_not have_css(locator, :text => text)
  else
    element = page.find(locator, :text => text)
    element.should_not(be_nil) && element.visible?.should(be_true)
  end
end

Then(/^I should see the option to create a new "(.*?)"$/) do |text|
  expect(page).to have_selector('option', :text => text)
end