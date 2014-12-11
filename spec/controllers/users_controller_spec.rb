require 'rails_helper'

RSpec.describe UsersController, :type => :controller do
  render_views

  include DataHelper
  
  before :each do
    test_data
  
    session[:user_id] = User.admin.id
    session[:expires_at] = Kor.session_expiry_time
  end
  
  it "should allow non user admins to change their profile" do
    john = FactoryGirl.create :jdoe
    session[:user_id] = john.id
  
    put :update_self, :user => {:home_page => '/entities/gallery'}
    
    expect(response).not_to redirect_to(denied_path)
  end
  
  it "should only grant access to the user admin to authorized users" do
    fake_authentication :user => FactoryGirl.create(:jdoe)
    get :index
    expect(response).to redirect_to('/authentication/denied')
  end

  it "should render a json formatted list of users for autocomplete inputs" do
    FactoryGirl.create :hmustermann
    FactoryGirl.create :jdoe

    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(User.admin)
    allow_any_instance_of(ApplicationController).to receive(:session_expired?).and_return(false)
    request.env["HTTP_ACCEPT"] = "application/json"

    get :index
    expect(response.status).to eq(200)
    expect(JSON.parse(response.body).size).to eq(2)

    get :index, :search_string => "doe"
    expect(JSON.parse(response.body).size).to eq(1)

    get :index, :search_string => "usterm"
    expect(JSON.parse(response.body).size).to eq(1)

    get :index, :search_string => "doesntexist"
    expect(JSON.parse(response.body).size).to eq(0)
  end

  it "should not allow to normal users to change their user rights" do
    jdoe = FactoryGirl.create :jdoe
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(jdoe)
    allow_any_instance_of(ApplicationController).to receive(:session_expired?).and_return(false)
    expect(jdoe.admin?).to be_falsey
    
    put :update_self, :user => {:admin => true}
    jdoe.reload
    expect(jdoe.admin?).to be_falsey
  end

  it "should allow changing other user's rights for admins" do
    jdoe = FactoryGirl.create :jdoe
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(User.admin)
    allow_any_instance_of(ApplicationController).to receive(:session_expired?).and_return(false)
    expect(jdoe.admin?).to be_falsey
    
    put :update, :id => jdoe.id, :user => {:admin => true}
    jdoe.reload
    expect(jdoe.admin?).to be_truthy
  end
  
end
