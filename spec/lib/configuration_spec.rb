require 'spec_helper'

describe "Configuration System" do
  it "should load configuration for all environments and merge them" do
    expect(YAML).not_to receive(:load_file).with("#{Rails.root}/config/kor.app.yml")
  
    expect(Kor.config['dev.value_a']).to eq("default.env")
    expect(Kor.config['dev.value_b']).to eq("default.all")
  end
  
  it "should prefer environment settings to all settings" do
    expect(YAML).not_to receive(:load_file).with("#{Rails.root}/config/kor.app.yml")
    
    expect(Kor.config['app.current_history_length']).to eq(5)
  end
end
