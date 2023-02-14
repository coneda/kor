require "rails_helper"

RSpec.describe IdentifiersController, type: :controller do
  render_views

  it 'should GET resolve (json)' do
    get :resolve, params: {id: leonardo.id}
    expect(response).to redirect_to("/entities/#{leonardo.id}")

    get :resolve, params: {id: leonardo.uuid}
    expect(response).to redirect_to("/entities/#{leonardo.id}")

    get :resolve, params: {id: leonardo.dataset['gnd_id']}
    expect(response).to redirect_to("/entities/#{leonardo.id}")

    get :resolve, params: {kind_id: people.id, id: leonardo.dataset['gnd_id']}
    expect(response).to redirect_to("/entities/#{leonardo.id}")
  end

  it 'should GET resolve (html)' do
    request.headers['accept'] = 'text/html'
    get :resolve, params: {id: leonardo.id}
    expect(response).to redirect_to("/#/entities/#{leonardo.id}")
  end

  it 'should resolve an entity by a identifier value including a dot' do
    leonardo = Entity.find_by! name: 'Leonardo'
    leonardo.dataset['gnd_id'] = 'BMN_2002.33a-b_view1_bw'
    leonardo.save!

    get :resolve, params: {kind: 'gnd_id', id: 'BMN_2002.33a-b_view1_bw'}
    expect(response).to redirect_to("/entities/#{leonardo.id}")
  end

  it 'should resolve to a 404 page when the identifier is not found' do
    get :resolve, params: {kind: 'x', id: '1234'}
    expect(response).to be_a_not_found

    get :resolve, params: {kind: 'x', id: '1234'}, format: 'html'
    expect(response).to be_a_not_found
    expect(response.content_type).to eq('text/plain; charset=utf-8')
  end

  it 'should resolve by medium id' do
    get :resolve, params: {kind: 'medium-id', id: picture_a.medium_id}
    expect(response).to redirect_to("/entities/#{picture_a.id}")
  end
end
