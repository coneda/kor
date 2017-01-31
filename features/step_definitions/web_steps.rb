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


When /^(?:|I )fill in "([^"]*)" with( quoted)? "([^"]*)"$/ do |field, quoted, value|
  value = "\"#{value}\"" if quoted == ' quoted'
  field = all(:css, field).first || find(:fillable_field, field)
  field.set value
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
  expect(page).to have_content(text)
end

Then /^(?:|I )should see \/([^\/]*)\/$/ do |regexp|
  regexp = ::Regexp.new(regexp)
  expect(page).to have_xpath('//*', :text => regexp)
end

Then /^(?:|I )should not see "([^\"]*)"$/ do |text|
  expect(page).to have_no_content(text)
end

Then /^(?:|I )should be on (.+)$/ do |page_name|
  uri = URI.parse(current_url)
  expected_path = path_to(page_name)
  expected_uri = URI.parse("#{uri.scheme}://#{uri.host}:#{uri.port}#{expected_path}")
  if page_name.match(/ path$/)
    uri.query = nil
    expected_uri.query = nil
  end
  expect(uri).to eq(expected_uri)
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
  attachments = page.all("##{attachment_id} .attachment")
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
  collections = collections.split('/').map{|c| Collection.find_by_name(c).id}
  page.find('form.kor_form a img[alt^=Pen]').click
  dialog = page.all(:css, '.ui-dialog').last
  dialog.all(:css, 'input[type=checkbox]').each do |input|
    input.click unless collections.include?(input.value.to_i)
  end
  dialog.all(:css, 'button').last.click
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

When /I debug/ do
  binding.pry
  x = 15
end

When(/^I print the url$/) do
  p current_url
end

When /^I wait for "([^"]*)" seconds?$/ do |num|
  sleep num.to_f
end

When /^I fill in "([^"]*)" with harmful code$/ do |field_name|
  harmful_code = "\\#\\{system 'touch tmp/harmful.txt'\\}"
  step "I fill in \"#{field_name}\" with \"#{harmful_code}\""
end

Then /^the harmful code should not have been executed$/ do
  expect(File.exists? "#{Rails.root}/tmp/harmful.txt").to be_falsey
end

When /^I click on the player link$/ do
  page.find('.viewer .kor_medium_frame a').click
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

Then(/^I should not see link "(.*?)"$/) do |text|
  expect(page).not_to have_link(text)
end

When(/^I click on the upper triangle for relation "(.*?)"$/) do |relation_name|
  title = page.find(".relation .subtitle", :text => relation_name)
  relation = title.find(:xpath, "..")
  relation.find(".relation_switch a").click
end

Then(/^I should see "(\d+)" kor images$/) do |amount|
  expect(page).to have_selector("img.kor_medium", :count => 2)
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

When(/^I click on entity "([^"]*)"$/) do |name|
  find('[kor-entity-widget]', :text => /#{name}/).click
end

Then(/^I should see "([^"]*)" gallery items?$/) do |amount|
  all('.gallery_item > div', count: amount.to_i, visible: true)
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
  first('.gallery_item .kor_medium_frame > a').click
end

When(/^I go back$/) do
  page.evaluate_script('window.history.back()')
end

When(/^I refresh the page$/) do
  page.evaluate_script("window.location.reload()")
end

Then(/^I should (not )?see an image$/) do |negation|
  if negation == 'not '
    expect(page).not_to have_selector("img[src]")
  else
    expect(page).to have_selector('img[src]')
  end
end

When(/^I paginate right in the relations$/) do
  within '.relation' do
    page.find("img[data-name='pager_right']").click
    # puts page.find("input[type=number]").value
    # expect(page).to have_content('ENDE')
  end
end