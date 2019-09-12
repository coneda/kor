require 'rails_helper'

RSpec.describe WikidataController, type: :request do
  it 'should simulate the import of an item' do
    expect{
      post '/wikidata/preflight', params: {
        id: 'Q762',
        locale: 'en',
        collection: 'Default',
        kind: 'person',
        api_key: User.admin.api_key
      }
      expect(response).to be_success
      expect(json['entity']['name']).to eq('Leonardo da Vinci')
    }.not_to(change{ Entity.count })
  end

  it 'should import an item' do
    expect{
      post '/wikidata/import', params: {
        id: 'Q762',
        locale: 'en',
        collection: 'Default',
        kind: 'person',
        api_key: User.admin.api_key
      }
      expect(response).to be_success
      expect(Entity.last.name).to eq('Leonardo da Vinci')
    }.to(change{ Entity.count }.by(1))
  end
end
