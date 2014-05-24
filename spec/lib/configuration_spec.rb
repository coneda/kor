require 'spec_helper'

describe "Configuration System" do
  it "should load configuration for all environments and merge them" do
    YAML.should_not_receive(:load_file).with("#{Rails.root}/config/kor.app.yml")
  
    Kor.config['dev.value_a'].should == "default.env"
    Kor.config['dev.value_b'].should == "default.all"
  end
  
  it "should prefer environment settings to all settings" do
    YAML.should_not_receive(:load_file).with("#{Rails.root}/config/kor.app.yml")
    
    Kor.config['app.current_history_length'].should == 5
  end
end
