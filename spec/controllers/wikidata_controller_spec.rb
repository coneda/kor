require 'rails_helper'

RSpec.describe WikidataController, type: :request do
  it "should not import an item if permissions don't allow it" do
    expect{
      post '/wikidata/import', params: {
        id: 'Q762',
        locale: 'en',
        collection_id: Collection.find_by!(name: 'Default').id,
        kind_id: Kind.find_by!(name: 'person').id
      }
      expect(response).to be_forbidden
    }.to change{ Entity.count }.by(0)
  end

  it 'should import an item' do
    expect{
      post '/wikidata/import', params: {
        id: 'Q762',
        locale: 'fr',
        collection_id: Collection.find_by!(name: 'Default').id,
        kind_id: Kind.find_by!(name: 'person').id,
        api_key: User.admin.api_key
      }
      expect(response).to be_successful
      expect(Entity.last.name).to eq('Léonard de Vinci')
    }.to(change{ Entity.count }.by(1))
  end
end
