require 'rails_helper'

RSpec.describe Api::Iiif::MediaController, type: :controller do
  render_views

  it 'should GET index' do
    request.headers["accept"] = 'text/html'

    get 'index'
    expect(response).to be_success
    expect(response.body).to match(/manifestUri/)
  end

  it 'should not GET show' do
    get 'show', id: picture_a.id
    expect(response).to be_forbidden
  end

  context 'as jdoe' do
    before :each do
      current_user jdoe
    end

    it 'should GET show' do
      get 'show', id: picture_a.id
      expect(response).to be_success
      expect(json['label']).to eq('entity 6')
    end
  end
end