require 'rails_helper'
require 'timeout'

RSpec.describe KorController, type: :controller do
  render_views

  it 'should render the api docs' do
    get :api
    expect(response).to be_successful
    expect(response.body).to have_text('ConedaKOR API Documentation')
  end
end