require 'rails_helper'

RSpec.describe 'terms acceptance', type: :controller do
  render_views

  context 'as jdoe without accepted terms' do
    before :each do
      jdoe.update terms_accepted: false
      current_user jdoe
    end

    it 'should not GET index' do
      @controller = EntitiesController.new
      get 'index'
      expect(json['message']).to eq('You have to accept our terms of use')
    end
  end
end
