# Then /^the application config file should include "([^"]*)" with "([^"]*)"$/ do |key, value|
#   expect(Kor::Config.new(Kor::Config.app_config_file)[key]).to eq(value)
# end

# Given(/^the config option "([^"]*)" is set to "([0-9\.]+)"$/) do |key, float_value|
#   Kor.config.update key => float_value.to_f
# end

Then("the config value {string} should be {string}") do |key, value|
  Kor.settings.ensure_fresh
  expect(Kor.settings[key]).to eq(value)
end
