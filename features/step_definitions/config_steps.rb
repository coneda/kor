Then /^the application config file should include "([^"]*)" with "([^"]*)"$/ do |key, value|
  expect(Kor::Config.new(Kor.app_config_file)[key]).to eq(value)
end
