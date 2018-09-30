require "rails_helper"

RSpec.describe IdentifiersController, :type => :controller do
  render_views

  it 'should GET resolve (json)' do
    leonardo = Entity.find_by! name: 'Leonardo'
    get :resolve, id: leonardo.id
    expect(response).to redirect_to("/entities/#{leonardo.id}")

    get :resolve, id: leonardo.uuid
    expect(response).to redirect_to("/entities/#{leonardo.id}")

    get :resolve, id: leonardo.dataset['gnd_id']
    expect(response).to redirect_to("/entities/#{leonardo.id}")

    people = Kind.find_by! name: 'person'
    get :resolve, kind_id: people.id, id: leonardo.dataset['gnd_id']
    expect(response).to redirect_to("/entities/#{leonardo.id}")
  end

  it 'should GET resolve (html)' do
    request.headers['accept'] = 'text/html'
    leonardo = Entity.find_by! name: 'Leonardo'
    get :resolve, id: leonardo.id
    expect(response).to redirect_to("/#/entities/#{leonardo.id}")
  end
end