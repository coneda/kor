Then /^I should see no categories nor groups$/ do
  page.should_not have_css('.authority_group_category')
  page.should_not have_css('.authority_group')
end

Then /^I should see no user groups$/ do
  page.should_not have_css('.user_group')
end
