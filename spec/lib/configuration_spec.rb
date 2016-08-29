require 'rails_helper'

describe "Configuration System" do

  it "should pick up mailer configuration from kor.defaults.yml" do
    dm = Rails.configuration.action_mailer
    expect(dm.delivery_method).to eq(:test)
  end

  it "should not write HashWithIndifferentAccess" do
    Kor::Config.instance.update(
      'mail' => {
        'smtp_settings' => HashWithIndifferentAccess.new('host' => 'localhost')
      }
    )

    Tempfile.create 'some' do |f|
      Kor::Config.instance.store f
      str = File.read(f)
      expect(str).not_to match(/HashWithIndifferentAccess/)
    end
  end

  # TODO: this doesn't test what is sais it does
  it "should load configuration for all environments and merge them" do
    expect(YAML).not_to receive(:load_file).with("#{Rails.root}/config/kor.app.yml")
  
    expect(Kor.config['auth.sources']).not_to be_nil
  end
  
  it "should prefer environment settings to all settings" do
    expect(YAML).not_to receive(:load_file).with("#{Rails.root}/config/kor.app.yml")
    
    expect(Kor.config['app.current_history_length']).to eq(5)
  end

end
