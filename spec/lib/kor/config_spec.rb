require 'rails_helper'

describe Kor::Config do

  def config(*args)
    @config ||= Kor::Config.new args
  end
  
  it "should expand paths starting at the rails root" do
    expect(Kor::Config.expand_path('config/app.yml')).to eql("#{Rails.root}/config/app.yml")
    expect(Kor::Config.expand_path('/config/app.yml')).to eql('/config/app.yml')
  end
  
  it "should not raise an error when a file is missing" do
    expect {
      config("/tmp/does_not_exist.yml")
    }.not_to raise_error
  end
  
  it "should create config files when storing" do
    allow(File).to receive(:open).and_return(
      Tempfile.new("test.yml")
    )
  
    expect {
      config('test' => 'value').store('/tmp/does_not_exist.yml')
    }.not_to raise_error
  end
  
  it "should split config names into an array" do
    expect(Kor::Config.array_for("section.value")).to eql(['section','value'])
  end
  
  it "should have a nil value as default" do
    expect(config['non_existing']).to be_nil
  end
  
  it "should retrieve values from config/kor.defaults.yml" do
    expect(YAML).to receive(:load_file).with("#{Rails.root}/config/kor.defaults.yml").and_return(
      'test' => {'test' => 'value'}
    )
    
    expect(config('config/kor.defaults.yml')['test']).to eql('value')
  end
  
  it "should sub-section the config into an environment when storing" do
    config('test' => 'value').store('tmp/test.yml')
    expect(File.exists?("#{Rails.root}/tmp/test.yml")).to be_truthy
    FileUtils.rm "#{Rails.root}/tmp/test.yml"
  end
  
  it "should store nil, booleans, strings and integers" do
    config['mail.smtp.domain'] = nil
    config['mail.smtp.ssl'] = true
    config['mail.smtp.auth'] = false
    config['mail.smtp.address'] = '127.0.0.1'
    config['mail.smtp.port'] = 25
    
    expect(config['mail.smtp.ssl']).to be_truthy
    expect(config['mail.smtp.auth']).to be_falsey
    expect(config['mail.smtp.domain']).to be_nil
    expect(config['mail.smtp.address']).to eql('127.0.0.1')
    expect(config['mail.smtp.port']).to eql(25)
  end
  
  it "should update attributes for a given section and not create a duplicate entry" do
    config['mail.sender_name'] = 'Administrator'
    config['mail.sender_name'] = 'John Doe'
    
    expect(config['mail.sender_name']).to eql('John Doe')
  end
  
  it "should destroy entire subtrees" do
    config['mail.sender_name'] = 'Administrator'
    config['mail.smtp.address'] = '127.0.0.1'
    
    config.clear 'mail'
    
    expect(config['mail']).to eql(nil)
  end
  
end
