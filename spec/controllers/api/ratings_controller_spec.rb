require 'spec_helper'

describe Api::RatingsController do

  before :each do
    request.env['HTTP_ACCEPT'] = 'application/json'
  end

  it "should not give access to unauthenticated users" do
    get :index
    response.status.should == 401
    
    get :show
    response.status.should == 401
    
    get :new
    response.status.should == 401
    
    post :create
    response.status.should == 401
    
    delete :destroy
    response.status.should == 401
  end
  
  it "should give access to actions new and create for authenticated users" do
    session[:user_id] = Factory.create(:user).id
    
    rating = Api::Rating.create(
      :namespace => "2d3d",
      :state => "open"
    )

    get :new, :namespace => "2d3d"
    response.status.should_not == 403
    
    post :create, :rating_id => rating.id
    response.status.should_not == 403
  end
  
  it "should not give access to actions index, show and destroy for non-rating-admins" do
    session[:user_id] = Factory.create(:user).id
    
    get :index
    response.status.should == 403
    
    get :show
    response.status.should == 403
    
    delete :destroy
    response.status.should == 403
  end
  
  it "should give access to all actions to rating-admins" do
    session[:user_id] = Factory.create(:admin).id
  
    rating = Api::Rating.create(
      :namespace => "2d3d",
      :state => "open"
    )

    get :index
    response.status.should_not == 403
    
    expect {get :show}.to raise_error(ActiveRecord::RecordNotFound)
    
    get :new, :namespace => "2d3d"
    response.status.should_not == 403
    
    post :create, :rating_id => rating.id
    response.status.should_not == 403
    
    expect {delete :destroy}.to raise_error(ActiveRecord::RecordNotFound)
    response.status.should_not == 403
  end
  
  it "should create a rating" do
    session[:user_id] = Factory.create(:admin).id
    mona_lisa = Factory.create(:mona_lisa)

    rating = Api::Rating.create(
      :namespace => "2d3d",
      :state => "open",
      :entity_id => mona_lisa.id
    )
    
    post :create, :rating_id => rating.id, :rating => {:data => ['2d']}
    response.status.should == 201

    rating = Api::Rating.first
    rating.namespace.should == '2d3d'
    rating.entity_id.should == mona_lisa.id
    rating.user_id.should == User.first.id
    rating.data.should == ['2d']
  end
  
  it "should destroy a rating" do
    session[:user_id] = Factory.create(:admin).id
    mona_lisa = Factory.create(:mona_lisa)
    rating = Factory.create(:rating, 
      :namespace => '2d3d', 
      :entity_id => mona_lisa.id, 
      :data => ['2d'], 
      :user_id => User.last.id
    )
    
    delete :destroy, :id => rating.id
    Api::Rating.count.should == 0
  end
  
end
