require 'rails_helper'

describe EntitiesController, :type => :controller do
  
  it "should allow guest requests" do
    guests = FactoryGirl.create :guests
    guest = FactoryGirl.create :guest, :groups => [guests]
    default = FactoryGirl.create :default
    Grant.create :collection => default, :credential => guests, :policy => "view"
    mona_lisa = FactoryGirl.create :mona_lisa

    get :show, :id => mona_lisa, :format => 'json'
    expect(response).to be_success
  end

end
