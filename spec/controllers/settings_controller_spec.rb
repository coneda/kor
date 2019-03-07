require 'rails_helper'

RSpec.describe SettingsController, type: :controller do
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
      current_user User.admin
    end

    it 'should allow updating configuration for admins' do
      put :update
      expect(response).to be_success
    end

    it 'should update the configuration' do
      put :update, params: { settings: { 'some' => 'value' } }
      Kor.settings.ensure_fresh
      expect(Kor.settings['some']).to eq('value')
    end

    it 'should update only parts of the configuration' do
      Kor.settings.update 'some' => 'value', 'other' => 'thing'
      put :update, params: { settings: { 'some' => '123' } }
      Kor.settings.ensure_fresh
      expect(Kor.settings['some']).to eq('123')
      expect(Kor.settings['other']).to eq('thing')
    end

    it 'should deny updating with stale configuration' do
      Kor.settings.update 'some' => '567'
      put :update, params: { settings: { 'some' => '123', 'version' => 0 } }
      Kor.settings.ensure_fresh
      expect(response.status).to eq(422)
    end
  end
end
