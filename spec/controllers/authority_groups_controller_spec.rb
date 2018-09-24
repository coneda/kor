require 'rails_helper'

RSpec.describe AuthorityGroupsController, type: :controller do

  include DataHelper

  it 'should put all entities within a group into the clipboard' do
    fake_authentication user: User.admin

    mona_lisa = Entity.find_by name: 'Mona Lisa'
    leonardo = Entity.find_by name: 'Leonardo da Vinci'
    group = AuthorityGroup.first
    group.add_entities [mona_lisa, leonardo]

    get :mark, id: group.id

    expect(User.admin.clipboard).to include(mona_lisa.id, leonardo.id)
  end

end