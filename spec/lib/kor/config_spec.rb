require 'spec_helper'

describe Kor::Config do

  def config(*args)
    @config ||= Kor::Config.new args
  end
  
  it "should expand paths starting at the rails root" do
    Kor::Config.expand_path('config/app.yml').should eql("#{Rails.root}/config/app.yml")
    Kor::Config.expand_path('/config/app.yml').should eql('/config/app.yml')
  end
  
  it "should not raise an error when a file is missing" do
    lambda {
      config("/tmp/does_not_exist.yml")
    }.should_not raise_error
  end
  
  it "should create config files when storing" do
    File.stub(:open).and_return(
      Tempfile.new("test.yml")
    )
  
    lambda {
      config('test' => 'value').store('/tmp/does_not_exist.yml')
    }.should_not raise_error
  end
  
  it "should split config names into an array" do
    Kor::Config.array_for("section.value").should eql(['section','value'])
  end
  
  it "should have a nil value as default" do
    config['non_existing'].should be_nil
  end
  
  it "should retrieve values from config/kor.defaults.yml" do
    YAML.should_receive(:load_file).with("#{Rails.root}/config/kor.defaults.yml").and_return(
      'test' => {'test' => 'value'}
    )
    
    config('config/kor.defaults.yml')['test'].should eql('value')
  end
  
  it "should sub-section the config into an environment when storing" do
    config('test' => 'value').store('tmp/test.yml')
    File.exists?("#{Rails.root}/tmp/test.yml").should be_true
    FileUtils.rm "#{Rails.root}/tmp/test.yml"
  end
  
  it "should store nil, booleans, strings and integers" do
    config['mail.smtp.domain'] = nil
    config['mail.smtp.ssl'] = true
    config['mail.smtp.auth'] = false
    config['mail.smtp.address'] = '127.0.0.1'
    config['mail.smtp.port'] = 25
    
    config['mail.smtp.ssl'].should be_true
    config['mail.smtp.auth'].should be_false
    config['mail.smtp.domain'].should be_nil
    config['mail.smtp.address'].should eql('127.0.0.1')
    config['mail.smtp.port'].should eql(25)
  end
  
  it "should update attributes for a given section and not create a duplicate entry" do
    config['mail.sender_name'] = 'Administrator'
    config['mail.sender_name'] = 'John Doe'
    
    config['mail.sender_name'].should eql('John Doe')
  end
  
  it "should destroy entire subtrees" do
    config['mail.sender_name'] = 'Administrator'
    config['mail.smtp.address'] = '127.0.0.1'
    
    config.clear 'mail'
    
    config['mail'].should eql(nil)
  end
  
end
