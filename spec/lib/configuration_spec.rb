require 'rails_helper'

describe "Configuration System" do

  # TODO: this doesn't test what is sais it does
  it "should load configuration for all environments and merge them" do
    expect(YAML).not_to receive(:load_file).with("#{Rails.root}/config/kor.app.yml")
  
    expect(Kor.config['cache_dir']).to eq("tmp/cache")
    expect(Kor.config['auth.sources']).not_to be_nil
  end
  
  it "should prefer environment settings to all settings" do
    expect(YAML).not_to receive(:load_file).with("#{Rails.root}/config/kor.app.yml")
    
    expect(Kor.config['app.current_history_length']).to eq(5)
  end
end
