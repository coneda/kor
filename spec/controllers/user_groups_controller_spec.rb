require 'rails_helper'

RSpec.describe UserGroupsController, :type => :controller do
  include DataHelper
  
  before :each do
    fake_authentication user: User.admin
  end
  
  it "should show GET '/user_groups/1'" do
    user_group = FactoryGirl.create :user_group
    
    get :show, :id => user_group.id, owner: User.admin
    expect(response).to be_success
  end

  it 'should put all entities within a group into the clipboard' do
    leonardo = Entity.find_by(name: 'Leonardo da Vinci')
    mona_lisa = Entity.find_by(name: 'Mona Lisa')

    group = FactoryGirl.create :user_group, owner: User.admin
    group.add_entities [mona_lisa, leonardo]

    get :mark, id: group.id

    expect(User.admin.clipboard).to include(mona_lisa.id, leonardo.id)
  end
  
end
  
