Given /^I am logged in as "([^\"]*)"/ do |user|
  # for the reset to work, the browser's current url has to match our origin
  visit '/'

  # we also have to make sure that the browser actually loaded the page
  expect(page).to have_content('Report a problem') # should always be visible

  # then we can reset
  Capybara.reset_sessions!
  
  # now we can be sure that we are logged out
  step "I go to the login page"

  begin
    fill_in 'Username', with: user
  rescue Capybara::ElementNotFound => e
    # TODO: why is this necessary?
    Capybara.reset_sessions!
    step "I go to the login page"
    fill_in 'Username', with: user
    # binding.pry
  end
  fill_in 'Password', with: user
  click_button 'Login'
  expect(page).to have_css('w-messaging .notice', text: 'you have been logged in')
end

# old?

Given /^the user "([^\"]*)"$/ do |user|
  unless User.exists? :name => user
    FactoryGirl.create :user, :name => user, :password => user, :email => "#{user}@example.com"
  end
end

Given /^the user "([^\"]*)" is a "([^\"]*)"$/ do |user, role|
  step "the user \"#{user}\""
  user = User.find_by_name(user)
  user.send("#{role}=".to_sym, true)
  user.save
end

Given /^the user "([^\"]*)" has password "([^\"]*)"$/ do |username, password|
  user = User.find_by!(name: username)
  user.update_attributes(
    password: password,
    make_personal: user.personal?,
    terms_accepted: true
  )
end

Given /^the user "([^\"]*)" with credential "([^\"]*)"$/ do |user, credential|
  step "the credential \"#{credential}\""
  step "the user \"#{user}\""
  user = User.find_by_name(user)
  credential = Credential.find_by_name(credential)
  user.groups << credential
  user.save
end

Given /^I re\-login as "([^"]*)"$/ do |user|
  step "I log out"
  step "I am logged in as \"#{user}\""
end

Given /^I log out$/ do
  step "I follow \"logout\""
end

When /^I mark "([^\"]*)" as current entity$/ do |name|
  step "I am on the entity page for \"#{name}\""
  step "I should see \"#{name}\""
  step "I follow \"mark\""
  step "I should see a message containing \"has been marked as current entity\""
end

When(/^I put "(.*?)" into the clipboard$/) do |name|
  step "I am on the entity page for \"#{name}\""
  step "I should see \"#{name}\""
  step "I follow \"add to clipboard\" within \".kor-layout-left\""
  step "I should see a message containing \"has been added to the clipboard\""
end

Given /^the session has expired$/ do
  allow_any_instance_of(BaseController).to receive(:session_expired?).and_return(true)
end

Given /^the session is not forcibly expired anymore$/ do
  allow_any_instance_of(BaseController).to receive(:session_expired?).and_call_original
end

Given /^"([^\"]*)" is expanded$/ do |folded_menu_name|
  case folded_menu_name
  when "Administration" 
    click_link "Administration"
  when "Groups"
    click_link "Groups"
  end
end

Given /^all entities of kind "([^\"]*)" are in the clipboard$/ do |kind|
  Kind.find_by!(name: kind.split("/").first).entities.each do |entity|
    step "I go to the entity page for \"#{entity.uuid}\""
    step "I should see \"#{entity.name}\""
    # TODO: why?
    sleep 2
    find('a.to-clipboard').click
    expect(page).to have_content('has been added to the clipboard')
  end
end

When(/^I save a screenshot$/) do
  page.save_screenshot "screenshot.png"
end

When(/^I call the inspector$/) do
  page.driver.debug
end

Given /^elasticsearch is (not )?available$/ do |negation|
  allow(Kor::Elastic).to receive(:available?).and_return(!negation)
end