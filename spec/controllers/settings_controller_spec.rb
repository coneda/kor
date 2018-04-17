require 'rails_helper'

RSpec.describe SettingsController, :type => :controller do
  it 'should show the configuration' do
    get :show
    expect(response).to be_success
  end

  it 'should deny updating configuration for non admins' do
    put :update
    expect(response).to have_http_status(403)
  end

  context 'as admin' do
    before :each do
      admin = FactoryGirl.create :admin
      session[:user_id] = admin.id
    end

    it 'should allow updating configuration for admins' do
      put :update
      expect(response).to be_success
    end

    it 'should update the configuration' do
      put :update, settings: {'some' => 'value'}
      expect(Kor.settings['some']).to eq('value')
    end

    it 'should update only parts of the configuration' do
      Kor.settings.update 'some' => 'value', 'other' => 'thing'
      put :update, settings: {'some' => '123'}
      expect(Kor.settings['some']).to eq('123')
      expect(Kor.settings['other']).to eq('thing')
    end

    it 'should deny updating with stale configuration' do
      Kor.settings.update 'some' => '567'
      put :update, settings: {'some' => '123'}, mtime: '2018-01-01'
      expect(response.status).to eq(406)
    end
  end
end
