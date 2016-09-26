require 'rails_helper'

describe AuthorityGroupsController, type: :controller do

  include DataHelper

  it 'should put all entities within a group into the clipboard' do
    default_setup

    admin = User.admin
    allow_any_instance_of(AuthorityGroupsController).to receive(:current_user).and_return(admin)
    mona_lisa = Entity.find_by name: 'Mona Lisa'
    leonardo = Entity.find_by name: 'Leonardo da Vinci'
    group = FactoryGirl.create :authority_group
    group.add_entities [mona_lisa, leonardo]

    get :mark, id: group.id

    expect(User.admin.clipboard).to include(mona_lisa.id, leonardo.id)
  end

end