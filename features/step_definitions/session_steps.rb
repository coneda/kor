Given /^I am logged in as "([^"]*)"/ do |user|
  reset_browser!
  # # for the reset to work, the browser's current url has to match our origin
  # visit '/info'

  # # we also have to make sure that the browser actually loaded the page, this
  # # content should always be visible
  # # expect(page).to have_content(/Report a problem|loading/)

  # # then we can reset
  # Capybara.reset_sessions!

  # now we can be sure that we are logged out
  step "I go to the login page"
  fill_in 'Username', with: user
  fill_in 'Password', with: user
  click_button 'Login'
  expect(page).to have_text('you have been logged in')
  # page.refresh
  expect(page).to have_text("logged in as: ")
end

Given /^the user "([^"]*)"$/ do |user|
  unless User.exists? :name => user
    FactoryBot.create :user, :name => user, :password => user, :email => "#{user}@example.com"
  end
end

Given /^the user "([^"]*)" has password "([^"]*)"$/ do |username, password|
  user = User.find_by!(name: username)
  user.update_attributes(
    password: password,
    make_personal: user.personal?,
    terms_accepted: true
  )
end

Given /^the user "([^"]*)" with credential "([^"]*)"$/ do |user, credential|
  step "the credential \"#{credential}\""
  step "the user \"#{user}\""
  user = User.find_by_name(user)
  credential = Credential.find_by_name(credential)
  user.groups << credential
  user.save
end

Given /^I re-login as "([^"]*)"$/ do |user|
  step "I log out"
  step "I am logged in as \"#{user}\""
end

Given /^I log out$/ do
  step "I follow \"logout\""
end

When(/^I put "(.*?)" into the clipboard$/) do |name|
  step "I am on the entity page for \"#{name}\""
  step "I should see \"#{name}\""
  step "I follow \"add to clipboard\" within \".kor-layout-left\""
  step "I should see a message containing \"has been added to the clipboard\""
end

When /^I travel "([^"]*)"$/ do |time|
  travel eval(time)
end

When /^I travel back$/ do
  travel_back
end

Given /^the session has expired$/ do
  allow_any_instance_of(BaseController).to receive(:session_expired?).and_return(true)
end

Given /^the session is not forcibly expired anymore$/ do
  allow_any_instance_of(BaseController).to receive(:session_expired?).and_call_original
end

Given /^all entities of kind "([^"]*)" are in the clipboard$/ do |kind|
  Kind.find_by!(name: kind.split("/").first).entities.each do |entity|
    step "I go to the entity page for \"#{entity.uuid}\""
    step "I should see \"#{entity.name}\""
    find('a.to-clipboard').click
    expect(page).to have_content('has been added to the clipboard')
  end
end

When(/^I save a screenshot$/) do
  page.save_screenshot "screenshot.png"
end

When /^I am not logged in$/ do
  if page.has_text?('logged in as: administrator')
    Capybara.reset_sessions!
    step 'I reload the page'
  end
end

Given("I set local storage {string} to {string}") do |key, value|
  page.evaluate_script("Lockr.set('#{key}', '#{value}')")
end

Then("I should not be logged in") do
  visit '/'
  expect(page).to have_text('logged in as: guest')
end

Then("local storage {string} should be empty") do |key|
  result = page.evaluate_script("Lockr.get('#{key}')")
  expect(result).to be_nil
end
