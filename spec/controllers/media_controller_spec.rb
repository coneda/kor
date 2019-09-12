require 'rails_helper'

RSpec.describe MediaController, type: :request do
  it 'should not GET show' do
    entity = Collection.find_by!(name: 'private').entities.media.first

    get entity.medium.url :icon
    expect(response).to be_forbidden

    get entity.medium.url :thumbnail
    expect(response).to be_forbidden

    get entity.medium.url :screen
    expect(response).to be_forbidden

    get entity.medium.url :normal
    expect(response).to be_forbidden

    get entity.medium.url :original
    expect(response).to be_forbidden
  end

  it 'should not GET download' do
    entity = Collection.find_by!(name: 'private').entities.media.first

    get entity.medium.url :icon, 'download'
    expect(response).to be_forbidden

    get entity.medium.url :thumbnail, 'download'
    expect(response).to be_forbidden

    get entity.medium.url :screen, 'download'
    expect(response).to be_forbidden

    get entity.medium.url :normal, 'download'
    expect(response).to be_forbidden

    get entity.medium.url :original, 'download'
    expect(response).to be_forbidden
  end

  it 'should not PATCH transform' do
    entity = Collection.find_by!(name: 'private').entities.media.first

    patch "/media/transform/#{entity.medium_id}/image/rotate_cw"
    expect(response).to be_forbidden

    patch "/media/transform/#{entity.medium_id}/image/flip"
    expect(response).to be_forbidden
  end

  context 'as publishment viewer' do
    it 'should GET show'
    it 'should not GET download'
    it 'should not PATCH transform'
  end

  context 'as jdoe' do
    before :each do
      current_user User.find_by!(name: 'jdoe')
    end

    it 'should not GET show' do
      entity = Collection.find_by!(name: 'private').entities.media.first

      get entity.medium.url :icon
      expect(response).to be_forbidden

      get entity.medium.url :thumbnail
      expect(response).to be_forbidden

      get entity.medium.url :screen
      expect(response).to be_forbidden

      get entity.medium.url :normal
      expect(response).to be_forbidden

      get entity.medium.url :original
      expect(response).to be_forbidden
    end

    it 'should not GET download' do
      entity = Collection.find_by!(name: 'private').entities.media.first

      get entity.medium.url :icon, 'download'
      expect(response).to be_forbidden

      get entity.medium.url :thumbnail, 'download'
      expect(response).to be_forbidden

      get entity.medium.url :screen, 'download'
      expect(response).to be_forbidden

      get entity.medium.url :normal, 'download'
      expect(response).to be_forbidden

      get entity.medium.url :original, 'download'
      expect(response).to be_forbidden
    end

    it 'should not PATCH transform' do
      entity = Collection.find_by!(name: 'private').entities.media.first

      patch "/media/transform/#{entity.medium_id}/image/rotate_cw"
      expect(response).to be_forbidden

      patch "/media/transform/#{entity.medium_id}/image/flip"
      expect(response).to be_forbidden
    end
  end

  context 'as jdoe (with download originals permission)' do
    before :each do
      priv = Collection.find_by! name: 'private'
      students = Credential.find_by! name: 'students'
      Kor::Auth.grant priv, :download_originals, to: students
      jdoe = User.find_by!(name: 'jdoe')

      current_user jdoe
    end

    it 'should not GET show' do
      entity = Collection.find_by!(name: 'private').entities.media.first

      get entity.medium.url :icon
      expect(response).to be_forbidden

      get entity.medium.url :thumbnail
      expect(response).to be_forbidden

      get entity.medium.url :screen
      expect(response).to be_forbidden

      get entity.medium.url :normal
      expect(response).to be_forbidden

      get entity.medium.url :original
      expect(response).to be_success
      expect(response.body).to eq(File.read entity.medium.path)
    end

    it 'should not GET download' do
      entity = Collection.find_by!(name: 'private').entities.media.first

      get entity.medium.url :icon, 'download'
      expect(response).to be_forbidden

      get entity.medium.url :thumbnail, 'download'
      expect(response).to be_forbidden

      get entity.medium.url :screen, 'download'
      expect(response).to be_forbidden

      get entity.medium.url :normal, 'download'
      expect(response).to be_forbidden

      get entity.medium.url :original, 'download'
      expect(response).to be_success
      expect(response.headers['content-disposition']).to match(/^attachment/)
      expect(response.body).to eq(File.read entity.medium.path)
    end

    it 'should not PATCH transform' do
      entity = Collection.find_by!(name: 'private').entities.media.first

      patch "/media/transform/#{entity.medium_id}/image/rotate_cw"
      expect(response).to be_forbidden

      patch "/media/transform/#{entity.medium_id}/image/flip"
      expect(response).to be_forbidden
    end
  end

  context 'as admin' do
    before :each do
      current_user User.admin
    end

    it 'should GET show' do
      entity = Collection.find_by!(name: 'private').entities.media.first

      get entity.medium.url :icon
      expect(response).to be_success
      expect(response.body).to eq(File.read entity.medium.path(:icon))

      get entity.medium.url :thumbnail
      expect(response).to be_success
      expect(response.body).to eq(File.read entity.medium.path(:thumbnail))

      get entity.medium.url :screen
      expect(response).to be_success
      expect(response.body).to eq(File.read entity.medium.path(:screen))

      get entity.medium.url :normal
      expect(response).to be_success
      expect(response.body).to eq(File.read entity.medium.path(:normal))

      get entity.medium.url :original
      expect(response).to be_success
      expect(response.body).to eq(File.read entity.medium.path)
    end

    it 'should GET download' do
      entity = Collection.find_by!(name: 'private').entities.media.first

      get entity.medium.url :icon, 'download'
      expect(response).to be_success
      expect(response.headers['content-disposition']).to match(/^attachment/)
      expect(response.body).to eq(File.read entity.medium.path(:icon))

      get entity.medium.url :thumbnail, 'download'
      expect(response).to be_success
      expect(response.headers['content-disposition']).to match(/^attachment/)
      expect(response.body).to eq(File.read entity.medium.path(:thumbnail))

      get entity.medium.url :screen, 'download'
      expect(response).to be_success
      expect(response.headers['content-disposition']).to match(/^attachment/)
      expect(response.body).to eq(File.read entity.medium.path(:screen))

      get entity.medium.url :normal, 'download'
      expect(response).to be_success
      expect(response.headers['content-disposition']).to match(/^attachment/)
      expect(response.body).to eq(File.read entity.medium.path(:normal))

      get entity.medium.url :original, 'download'
      expect(response).to be_success
      expect(response.headers['content-disposition']).to match(/^attachment/)
      expect(response.body).to eq(File.read entity.medium.path(:original))
    end

    it 'should PATCH transform' do
      entity = Collection.find_by!(name: 'private').entities.media.first

      patch "/media/transform/#{entity.medium_id}/image/rotate_cw"
      expect(response).to be_success
      expect(json['message']).to eq('medium has been transformed')

      patch "/media/transform/#{entity.medium_id}/image/flip"
      expect(response).to be_success
      expect(json['message']).to eq('medium has been transformed')
    end

    it 'should respond to byte ranges' do
      entity = Collection.find_by!(name: 'private').entities.media.first

      get entity.medium.url(:original)
      expect(response.status).to eq(200)
      expect(response.body.bytesize).to eq(File.size entity.medium.path)

      get entity.medium.url(:thumbnail)
      expect(response.status).to eq(200)
      expect(response.body.bytesize).to eq(File.size(entity.medium.path(:thumbnail)))

      get entity.medium.url(:thumbnail), headers: {'Range' => 'bytes=0-1'}
      expect(response.status).to eq(206)
      expect(response.headers['Content-Range']).to eq(
        "bytes 0-1/#{File.size(entity.medium.path(:thumbnail))}"
      )
      expect(response.body.bytesize).to eq(2)

      get entity.medium.url(:thumbnail), headers: {'Range' => 'bytes=0-100'}
      expect(response.status).to eq(206)
      expect(response.body.bytesize).to eq(101)
    end
  end
end
