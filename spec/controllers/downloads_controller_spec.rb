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
    expect(response).to be_success
    expect(response.body).to match(/ConedaKOR is a web based application/)
  end

  context 'as jdoe' do
    before :each do
      current_user User.find_by!(name: 'jdoe')
    end

    it 'should GET show (foreground download)' do
      Kor.settings.update 'max_foreground_group_download_size' => '0.1'
      nice = UserGroup.find_by! name: 'nice'

      zip_file = Kor::ZipFile.create(
        jdoe.id, 'UserGroup', nice.id, nice.entities.pluck(:id)
      )
      download = zip_file.build

      get 'show', params: {uuid: download.uuid}
      expect(response).to be_success
      expect(response.body.size).to be_within(1000).of(264872)
    end
  end
end
