require 'rails_helper'

RSpec.describe Kor::Settings do
  it "should create the settings file if it doesn't exist" do
    system "rm #{described_class.filename}"
    subject.save
    expect(File.exist?(described_class.filename)).to be_truthy
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

  it 'should reload the file' do
    expect(subject['some']).to be_nil
    system "echo '{\"some\": \"value\"}' > #{described_class.filename}"
    subject.ensure_fresh
    expect(subject['some']).to eq('value')
  end

  it 'should not raise an error when the file is missing' do
    expect{
      subject['something']
    }.not_to raise_error
  end

  it 'should have a nil value as default' do
    expect(subject['nothing']).to eq(nil)
  end

  it 'should separate the rails envs' do
    expect(described_class.filename.to_s).to match(/\/settings\.test\.json$/)
  end

  it 'should store nil, booleans, strings, integers, floats and arrays' do
    subject.update(
      'nothing' => nil,
      'awesome' => true,
      'stale' => false,
      'some' => 'value',
      'size' => 12,
      'average' => 10.5,
      'list' => [1, 'stuff']
    )

    expect(subject['nothing']).to eq(nil)
    expect(subject['list']).to eq([1, 'stuff'])
  end

  it 'should return defaults when the value is missing' do
    expect(subject['session_lifetime']).to eq(60 * 60 * 2)
  end
end
