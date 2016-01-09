require 'rails_helper'

RSpec.describe UserGroupsController, :type => :controller do
  include DataHelper
  
  before :each do
    test_data
  
    session[:user_id] = User.admin.id
    session[:expires_at] = Kor.session_expiry_time
  end
  
  it "should show GET '/user_groups/1'" do
    user_group = FactoryGirl.create :user_group
    
    get :show, :id => user_group.id
    expect(response).to be_success
  end
  
end
  
