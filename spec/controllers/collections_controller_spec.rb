require 'spec_helper'

describe CollectionsController do
  include DataHelper
  include AuthHelper

  before :each do
    fake_authentication :persist => true
  end
  
  it "should update" do
    collection = Collection.make(:name => 'Test Collection')
    
    put :update, :id => collection.id, :collection => {
      'grants_by_policy' => {
        'view' => [@admins.id.to_s]
    }}
    
    response.should redirect_to(collections_path)
    Collection.last.grants.with_policy(:view).map{|g| g.credential}.should == [@admins]
  end
  
end
