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
  page.find('form.kor_form a img[alt=Pen]').click
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
  step "I select \"Begriff '#{pattern}'\" from the autocomplete"
end

When /^I fill in "([^\"]*)" with "([^\"]*)" and select tag "([^\"]*)"$/ do |field, value, pattern|
  step "I fill in \"#{field}\" with \"#{value}\""
  step "I select \"Tag: #{pattern}\" from the autocomplete"
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

When /^I send the credential "([^\"]*)"$/ do |attributes|
  fields = attributes.split(',').map{|a| a.split(':')}
  attributes = {}
  fields.each{|f| attributes[f.first.to_sym] = f.last}
  Capybara.current_session.driver.send :post, '/credentials', :credential => attributes
  Capybara.current_session.driver.browser.follow_redirect!
end

When /^I send the delete request for "([^\"]*)" "([^\"]*)"$/ do |object_type, object_name|
  object = object_type.classify.constantize.find_by_name(object_name)
  Capybara.current_session.driver.send :delete, send(object_type + '_path', object)
  Capybara.current_session.driver.browser.follow_redirect!
end

When /^I send the mark request for entity "([^\"]*)"$/ do |entity|
  entity = Entity.find_by_name(entity)
  Capybara.current_session.driver.send :delete, put_in_clipboard_path(:id => entity.id, :mark => 'mark')
  if page.status_code >= 300 && page.status_code < 400
    Capybara.current_session.driver.browser.follow_redirect!
  end
end

When /^I send the mark as current request for entity "([^\"]*)"$/ do |entity|
  entity = Entity.find_by_name(entity)
  Capybara.current_session.driver.send :delete, mark_as_current_path(:id => entity.id), {}, {'HTTP_REFERER' => '/'}
  if page.status_code >= 300 && page.status_code < 400
    Capybara.current_session.driver.browser.follow_redirect!
  end
end

When /^I send a "([^\"]*)" request to "([^\"]*)" with params "([^\"]*)"$/ do |method, url, params|
  Capybara.current_session.driver.send method.downcase.to_sym, url, eval(params)
  if page.status_code >= 300 && page.status_code < 400
    Capybara.current_session.driver.browser.follow_redirect!
  end
end

Then /^I should get access "([^\"]*)"$/ do |access|
  step "I should not be on the denied page" if access == 'yes'
  step "I should be on the denied page"   if access == 'no'
end

When /^I ignore the next confirmation box$/ do
  page.evaluate_script('window.confirm = function() { return true; }')
end

When /^I click(?: on)? element "([^\"]+)"$/ do |selector|
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
  expect(page).to have_selector('.video-js')
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
