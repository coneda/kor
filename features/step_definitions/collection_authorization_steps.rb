Then /^I should see no categories nor groups$/ do
  expect(page).not_to have_css('.authority_group_category')
  expect(page).not_to have_css('.authority_group')
end

Then /^I should see no user groups$/ do
  expect(page).not_to have_css('.user_group')
end
