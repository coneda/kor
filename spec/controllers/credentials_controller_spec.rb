require 'rails_helper'

describe CredentialsController, type: :controller do

  it 'should not allow creation to non admins' do
    session[:user_id] = FactoryGirl.create(:jdoe).id
    session[:expires_at] = Kor.session_expiry_time

    post :create, credential: {
      name: 'Freaks',
      description: 'The KOR-Freaks'
    }
    expect(response.status).to eq(403)
  end

end