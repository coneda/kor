When("I click icon {string}") do |string|
  find("a[title='#{string}']").click
end

Then("I should not see icon link {string}") do |string|
  expect(page).not_to have_css("a[title='#{string}']")
end


# old?

require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "selectors"))

When /^(.*) within (.+)$/ do |step, parent|
  within find(*selector_for(parent)) do
    step(step)
  end
end

Given /^(?:|I )am on (.+)$/ do |page_name|
  visit path_to(page_name)
end

When /^(?:|I )go to (.+)$/ do |page_name|
  visit path_to(page_name)
end

When "I click {string}" do |string|
  click_on(string)
end

When /^(?:|I )press "([^"]*)"$/ do |button|
  click_button(button)
end

When /^(?:|I )follow "([^"]*)"$/ do |locator|
  find_link(locator).click
end

When /^(?:|I )click button "([^"]*)"$/ do |locator|
  find_button(locator).click
end

When(/^I follow the link with text "([^"]*)"$/) do |text|
  click_link(text)
end

When("I scroll down") do
  # sometimes, capybara doesn't correctly scroll to a button before clicking it
  sleep 1
  page.execute_script "window.scrollBy(0,10000)"
end

# When /^(?:|I )fill in "([^"]*)" with( quoted)? "([^"]*)"$/ do |locator, quoted, value|
#   value = "\"#{value}\"" if quoted == ' quoted'

#   timeout = 5.0
#   field = nil
#   while timeout > 0 && !field
#     field = page.first(:field, locator) || all(:css, locator).first
#     timeout -= 0.2
#     sleep 0.2
#   end
#   # field = all(:css, locator).first || find(:fillable_field, locator)
#   # binding.pry if locator.match /Label/
#   field.set value
# end

When("I fill in {string} with {string}") do |field, value|
  fill_in field, with: value
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

Given("I choose {string} for {string}") do |value, field|
  choose field, option: value
end

When /^(?:|I )attach the file "([^"]*)" to "([^"]*)"$/ do |path, field|
  attach_file(field, File.expand_path(path))
end

Then /^(?:|I )should see "([^"]*)"(?: exactly "(\d+)" times?)?$/ do |text, amount|
  amount = amount.to_i if amount
  if amount
    expect(page).to have_content(text, count: amount)
  else
    expect(page).to have_content(text)
  end
end

Then /^(?:|I )should see \/([^\/]*)\/$/ do |regexp|
  regexp = ::Regexp.new(regexp)
  expect(page).to have_xpath('//*', :text => regexp)
end

Then /^(?:|I )should not see "([^\"]*)"$/ do |text|
  expect(page).to have_no_content(text)
end

Then /^(?:|I )should be on (.+)$/ do |page_name|
  capybara_wait do
    uri = URI.parse(current_url)
    expected_path = path_to(page_name)
    expected_uri = URI.parse("#{uri.scheme}://#{uri.host}:#{uri.port}#{expected_path}")
    if page_name.match(/ path$/)
      uri.query = nil
      expected_uri.query = nil
    end
    expect(uri).to eq(expected_uri)
  end
end

Then /^I should( not)? see element "(.*?)" with text "(.*?)"$/ do |negative, locator, text|
  if negative == " not"
    expect(page).not_to have_css(locator, :text => text)
  else
    element = page.find(locator, :text => text)
    expect(element).not_to be_nil
    expect(element.visible?).to be_truthy
  end
end

Then(/^I should see the option to create a new "(.*?)"$/) do |text|
  expect(page).to have_selector('option', :text => text)
end

Then /^I should (not )?see element "([^\"]*)"$/ do |yesno, selector|
  if yesno == 'not '
    if (elements = page.all(selector)).size > 0
      elements.each do |element|
        expect(element.visible?).to be_falsey
      end
    else
      expect(page).not_to have_css(selector)  
    end
  else
    expect(page).to have_css(selector)
  end
end

When /^I fill in "([^"]*)" attachment "([^"]*)" with "([^"]*)"$/ do |attachment_id, index, values|
  values = values.split('/')
  attachments = page.all("##{attachment_id} .attachment", minimum: index.to_i)
  attachments[index.to_i - 1].all('input[type=text]').each_with_index do |input, i|
    input.set(values[i]) unless values[i].blank?
  end
end

Then /^I should (not )?really see element "([^\"]*)"$/ do |yesno, selector|
  page.all(selector).each do |element|
    if yesno == 'not '
      expect(element.visible?).to be_falsey
    else
      expect(element.visible?).to be_truthy
    end
  end
end

When /^I select "([^\"]*)" from the collections selector$/ do |collections|
  names = collections.split('/')
  within('kor-collection-selector'){click_link('edit')}
  click_link 'none'
  names.each do |name|
    check name
  end
  click_button 'ok'
end

Then /^I should see "([^"]*)" before "([^"]*)"$/ do |preceeding, following|
  expect(page.body).to match(/#{preceeding}.*#{following}/m)
end

Then /^I hover element "([^\"]*)"$/ do |selector|
  page.execute_script("jQuery('#{selector}').mouseover()")
end

Then /^I should see an input with the current date$/ do
  expect(page).to have_field("user_group_name", :with => Time.now.strftime("%d.%m.%Y"))
end

When /^(?:|I )unselect "([^\"]*)" from "([^\"]*)"(?: within "([^\"]*)")?$/ do |value, field, selector|
  if selector
    within(:css, selector) do
      unselect(value, :from => field)
    end
  else
    unselect(value, :from => field)
  end
end

When /^I fill in "([^\"]*)" with "([^\"]*)" and select term "([^\"]*)"$/ do |field, value, pattern|
  step "I fill in \"#{field}\" with \"#{value}\""
  step "I select \"terms '#{pattern}'\" from the autocomplete"
end

When /^I fill in "([^\"]*)" with "([^\"]*)" and select tag "([^\"]*)"$/ do |field, value, pattern|
  step "I fill in \"#{field}\" with \"#{value}\""
  step "I select \"tag: #{pattern}\" from the autocomplete"
end

When /^I select "([^\"]*)" from the autocomplete$/ do |pattern|
  page.execute_script '$("input[name=search_terms]").keydown()'

  t = Time.now
  while Time.now - t < 5.seconds && !page.all('li.ui-menu-item a').to_a.find{|a| a.text.match ::Regexp.new(pattern)}
    sleep 0.2
  end

  page.all('li.ui-menu-item a').to_a.find do |anchor|
    anchor.text.match ::Regexp.new(pattern)
  end.click
end

When /^I send a "([^\"]*)" request to "([^\"]*)" with params "([^\"]*)"$/ do |method, url, params|
  Capybara.current_session.driver.send method.downcase.to_sym, url, eval(params)
  if page.status_code >= 300 && page.status_code < 400
    Capybara.current_session.driver.browser.follow_redirect!
  end
end

When /^I ignore the next confirmation box$/ do
  page.evaluate_script('window.confirm = function() { return true; }')
end

When /^I click(?: on)? element "([^\"]+)"( again)?$/ do |selector, x|
  page.find(selector).click
end

When /^I follow the delete link$/ do
  step "I ignore the next confirmation box"
  click_link 'X'
end

When /^I click on "([^\"]*)"$/ do |selector|
  element = page.find(selector)
  element.click
end

Then /^(?:|I )should not be on (.+)$/ do |page_name|
  current_path = URI.parse(current_url).path
  expect(current_path).not_to eq(path_to(page_name))
end

Then /^I should have access: (yes|no)$/ do |yesno|
  if yesno == 'yes'
    expect(page).not_to have_content('Zugriff wurde verweigert')
  else
    expect(page).to have_content('Zugriff wurde verweigert')
  end
end

When /^I wait for "([^"]*)" seconds?$/ do |num|
  sleep num.to_f
end

Then /^I should see the video player$/ do
  expect(page).to have_selector('video')
end

Then(/^I should (not )?see option "([^\"]+)"$/) do |negator, text|
  if negator == "not "
    expect(page).not_to have_selector("option", :text => text)
  else
    expect(page).to have_selector("option", :text => text)
  end
end

Then(/^I should see a link "(.*?)" leading to "(.*?)"$/) do |text, href|
  expect(page.find_link(text)['href']).to match(href)
end

Then(/^I should (not )?see link "([^\"]+)"$/) do |negate, text|
  if negate.present?
    expect(page).not_to have_link(text, exact: true)
  else
    expect(page).to have_link(text, exact: true)
  end
end

# When(/^I click on the upper triangle for relation "(.*?)"$/) do |relation_name|
#   title = page.find(".relation .subtitle", :text => relation_name)
#   relation = title.find(:xpath, "..")
#   relation.find(".relation_switch a").click
# end

Then(/^I should see "(\d+)" kor images$/) do |amount|
  expect(page).to have_selector("img.medium", count: amount.to_i)
end

Then(/^I should see "(.*?)"'s API Key$/) do |username|
  user = User.where(:name => username).first
  expect(find_field("user[api_key]").value).to eq(user.api_key)
end

When(/^I trigger the blur event for "(.*?)"$/) do |selector|
  page.execute_script("$('#{selector}').blur()")
end

When(/^I uncheck the checkbox$/) do
  find("input[type=checkbox]").set false
end

Then(/^the checkbox should (not )?be checked$/) do |yesno|
  if yesno == "not "
    expect(find("input[type=checkbox]").checked?).to be(false)
  else
    expect(find("input[type=checkbox]").checked?).to be(true)
  end
end

Then("checkbox {string} should be checked") do |locator|
  expect(page).to have_checked_field(locator)
end

When(/^I click on entity "([^"]*)"$/) do |name|
  find('[kor-entity-widget]', :text => /#{name}/).click
end

Then(/^I should see "([^"]*)" gallery items?$/) do |amount|
  all('kor-gallery-grid kor-entity', count: amount.to_i, visible: true)
end

Then(/^the current js page should be "([^"]*)"$/) do |expected|
  params = {}
  fragment = URI.parse(current_url).fragment || ''
  fragment.split('?').last.split('&').each do |pair|
    key, value = pair.split('=')
    params[key] = value
  end
  page = (params['page'] || 1).to_i

  expect(page).to eq(expected.to_i)
end

When(/^I click the first gallery item$/) do
  first('kor-gallery-grid kor-entity > a').click
end

When(/^I go back$/) do
  page.evaluate_script('window.history.back()')
end

When(/^I (?:refresh|reload) the page$/) do
  page.evaluate_script("window.location.reload()")
end

Then(/^I should (not )?see an image$/) do |negation|
  if negation == 'not '
    expect(page).not_to have_selector("img[src]")
  else
    expect(page).to have_selector('img[src]')
  end
end

# When(/^I paginate right in the relations$/) do
#   within '.relation' do
#     page.find("img[data-name='pager_right']").click
#     # puts page.find("input[type=number]").value
#     # expect(page).to have_content('ENDE')
#   end
# end

Then(/^the select "([^"]*)" should have value "([^"]*)"$/) do |name, value|
  field = page.find_field(name)
  values = field.all('option[selected]').map{|o| o.text}
  if field['multiple'].present?
    expect(values).to eql(value.split ',')
  else
    expect(values.first).to eql(value)
  end
end

Then(/^options? "([^"]*)" from "([^"]*)" should be selected$/) do |value, field|
  step "the select \"#{field}\" should have value \"#{value}\""
end


Then(/^"([^"]*)" should not have option "([^"]*)"$/) do |name, value|
  field = page.find_field(name)
  options = field.all('option').map{|o| o.text}
  expect(options).not_to include(value)
end

# When(/^I click icon "([^"]*)"$/) do |name|
#   page.find("i.fa.fa-#{name}").click
# end

Then(/^select "([^"]*)" should be disabled$/) do |label|
  field = page.find_field(label, disabled: :all) 
  expect(field['disabled']).to be_present
end

# Then(/^I should( not)? see icon "([^"]*)"$/) do |negation, icon|
#   if negation
#     expect(page).to have_no_css("i.fa.fa-#{icon}")
#   else
#     expect(page).to have_css("i.fa.fa-#{icon}")
#   end
# end

And(/^I should see a message containing "([^"]*)"$/) do |pattern|
  page.find("w-messaging", text: /#{pattern}/)
end

Then(/^select "([^"]*)" should have selected "([^"]*)"$/) do |field, value|
  expect(find_field(field).value).to eq(value)
end

Then(/^field "([^"]*)" should have value "([^"]*)"$/) do |field, value|
  expect(find_field(field).value).to eq(value)
end

Then(/^I should see the prefilled dating "([^"]*)"$/) do |dating|
  label, value = dating.split(/: ?/)
  within "kor-datings-editor" do
    expect(page).to have_field('Type of dating', with: label)
    expect(page).to have_field('Dating', with: value)
  end
end

Then(/^select "([^"]*)" should have( no)? option "([^"]*)"$/) do |name, negation, option|
  options = page.find("select[name=#{name}]").all('option')

  if negation == ' no'
    options.all?{|o| o.text != option}
  else
    options.any?{|o| o.text == option}
  end
end

Then /^I should see no categories nor groups$/ do
  expect(page).not_to have_css('.authority_group_category')
  expect(page).not_to have_css('.authority_group')
end

Then /^I should see no user groups$/ do
  expect(page).not_to have_css('.user_group')
end

Then("I should see field {string}") do |string|
  expect(page).to have_field(string)
end

Then("I should see error {string} on field {string}") do |error, field|
  input = find("kor-input[label='#{field}']")
  expect(input).to have_css('.errors', text: error)
end

When("I fill in synonyms with {string}") do |string|
  fill_in 'Synonyms', with: string.split('|').join("\n")
end

Then /^image "([^"]*)" should have (portrait|landscape) orientation$/ do |locator, orientation|
  img = find(locator)

  capybara_wait do
    width = img.native.css_value('width').to_i
    height = img.native.css_value('height').to_i

    if orientation == 'landscape'
      expect(width).to be > height
    end

    if orientation == 'portrait'
      expect(width).to be < height
    end
  end
end

Then("I should see a check mark") do
  expect(page).to have_css('i.fa.fa-check')
end