require 'fileutils'
require 'rails_helper'

RSpec.describe OaiPmh::BaseController, type: :request do
  it 'should cleanup resumption tokens' do
    system("rm -rf #{subject.send(:base_dir)}")
    system("mkdir -p #{subject.send(:base_dir)}")

    old_sample = "#{subject.send(:base_dir)}/old_sample.json"
    recent_sample = "#{subject.send(:base_dir)}/recent_sample.json"
    FileUtils.touch old_sample, mtime: 10.minutes.ago.to_time
    FileUtils.touch recent_sample, mtime: 2.minutes.ago.to_time

    subject.send(:dump_query, 'some' => 'value')

    expect(File.exist?(old_sample)).to be_falsey
    expect(File.exist?(recent_sample)).to be_truthy
  end
end
