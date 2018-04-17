require 'rails_helper'

describe Kor::Settings do

  it "should create the settings file if it doesn't exist" do
    expect(File.exists?(described_class.filename)).to be_falsey
    subject.save
    expect(File.exists?(described_class.filename)).to be_truthy
  end

  it 'should load existing configuration' do
    File.open described_class.filename, 'w' do |f|
      data = {'some' => 'value'}.to_json
      f.write data
    end
    expect(subject['some']).to eq('value')
  end

  it 'should persist new configuration' do
    subject.update 'turbos' => 5
    expect(subject['turbos']).to eq(5)
    subject.load
    expect(subject['turbos']).to eq(5)
  end

  it 'should overwrite only new configuration' do
    File.open described_class.filename, 'w' do |f|
      data = {'some' => 'value'}.to_json
      f.write data
    end

    subject.update 'turbos' => 5
    expect(subject['some']).to eq('value')
    expect(subject['turbos']).to eq(5)
  end

  it 'should not overwrite config with stale values' do
    a = described_class.new
    b = described_class.new

    a.update 'some' => 'value'
    b.update 'some' => 'othervalue'

    expect(b.errors).to include('The configuration has been changed in the meantime')
  end

  it 'should reload when the file has been changed' do
    expect(subject).to receive(:load).once.and_call_original
    system "echo '{\"some\": \"value\"}' > #{described_class.filename}"
    subject['something']
    subject['something_else']
  end

  it 'should reload when another instance modifies the config' do
    a = described_class.new
    subject.update 'some' => 'value'
    expect(a['some']).to eq('value')
  end
  
  it 'should not raise an error when the file is missing' do
    expect {
      subject['something']
    }.not_to raise_error
  end
  
  it 'should have a nil value as default' do
    expect(subject['nothing']).to eq(nil)
  end

  it 'should separate the rails envs' do
    expect(described_class.filename.to_s).to match(/\/settings\.test\.json$/)
  end
  
  it 'should store nil, booleans, strings, integers and floats' do
    subject.update(
      'nothing' => nil,
      'awesome' => true,
      'stale' => false,
      'some' => 'value',
      'size' => 12,
      'average' => 10.5
    )

    expect(subject['nothing']).to eq(nil)
  end

  it 'should return defaults when the value is missing' do
    expect(subject['session_lifetime']).to eq(60 * 60 * 2)
  end

end
