Then /^the application config file should include "([^"]*)" with "([^"]*)"$/ do |key, value|
  Kor::Config.new(Kor.app_config_file)[key].should == value
end
