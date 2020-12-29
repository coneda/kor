require 'rails_helper'

RSpec.describe Iiif::MediaController, type: :controller do
  render_views

  it 'should GET index' do
    request.headers["accept"] = 'text/html'

    get 'index'
    expect(response).to be_success
    expect(response.body).to match(/manifestUri/)
  end

  it 'should not GET show' do
    get 'show', params: {id: picture_a.id}
    expect(response).to be_forbidden
  end

  context 'as jdoe' do
    before :each do
      current_user jdoe
    end

    it 'should GET show' do
      get 'show', params: {id: picture_a.id}
      expect(response).to be_success
      expect(json['label']).to eq('entity 6')
    end

    it 'should GET show with alternate manifest' do
      Kor.settings.update(
        'mirador_manifest_template' => 'spec/fixtures/manifest.json.jbuilder'
      )

      get 'show', params: {id: picture_a.id}
      expect(response).to be_success
      expect(json['id']).to eq(picture_a.id)
      expect(json['label']).to eq('An alternate manifest')
    end
  end
end
