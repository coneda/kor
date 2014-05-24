When /^I simple search for kind "([^"]*)" with terms "([^"]*)"$/ do |kind, terms|
  step "I go to the simple search page"
  step "I select \"#{kind}\" from \"kind_id\""
  step "I fill in \"search_terms\" with \"#{terms}\""
  step "I press \"Suchen\""
end

Then /^I should have search results "([^"]*)"$/ do |results|
  results = results.split('/').sort
  page.all("td.search_result .name").map{|t| t.text}.sort.should eql(results)
end
