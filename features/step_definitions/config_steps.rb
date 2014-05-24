Then /^config value "([^"]*)" should be "([^"]*)"$/ do |name, value_str|
  Kor.config[name].to_s.should eql(value_str)
end

Given /^config value "([^"]*)" is set to "([^"]*)"$/ do |name, value_str|
  Kor.config[name] = value_str
end

Then /^the application config file should include "([^"]*)" with "([^"]*)"$/ do |key, value|
  Kor::Config.new(Kor.app_config_file)[key].should == value
end
