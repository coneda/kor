require 'rails_helper'

RSpec.describe DownloadsController, type: :controller do
  it 'should not GET show (wrong hash)' do
    download = Download.create(
      file_name: 'test.zip',
      user: User.first,
      data: File.open("README.md")
    )

    get 'show', params: {uuid: download.id}
    expect(response).to be_not_found
  end

  it 'should GET show (correct hash)' do
    download = Download.create(
      file_name: 'test.zip',
      user: User.first,
      data: File.open("README.md")
    )

    get 'show', params: {uuid: download.uuid}
    expect(response).to be_successful
    expect(response.body).to match(/ConedaKOR is a web based application/)
  end
end
