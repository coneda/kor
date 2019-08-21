require "rails_helper"

RSpec.describe IdentifiersController, :type => :controller do
  render_views

  it 'should GET resolve (json)' do
    get :resolve, params: { id: leonardo.id }
    expect(response).to redirect_to("/entities/#{leonardo.id}")

    get :resolve, params: { id: leonardo.uuid }
    expect(response).to redirect_to("/entities/#{leonardo.id}")

    get :resolve, params: { id: leonardo.dataset['gnd_id'] }
    expect(response).to redirect_to("/entities/#{leonardo.id}")

    get :resolve, params: { kind_id: people.id, id: leonardo.dataset['gnd_id'] }
    expect(response).to redirect_to("/entities/#{leonardo.id}")
  end

  it 'should GET resolve (html)' do
    request.headers['accept'] = 'text/html'
    get :resolve, params: { id: leonardo.id }
    expect(response).to redirect_to("/#/entities/#{leonardo.id}")
  end
end
