require 'rails_helper'

RSpec.describe Api::WikidataController, type: :controller do

  before :each do
    @default = FactoryGirl.create :default
    @admins = FactoryGirl.create :admins
    @admin = FactoryGirl.create :admin, groups: [@admins]
    Kor::Auth.grant @default, :create, to: @admins
    @people = FactoryGirl.create :people, fields: [Field.new(name: 'wikidata_id', show_label: 'Wikidata ID', is_identifier: true)]
    @works = FactoryGirl.create :works, fields: [Field.new(name: 'wikidata_id', show_label: 'Wikidata ID', is_identifier: true)]
  end

  it 'should simulate the import of an item' do
    post(:preflight,
      id: 'Q762',
      locale: 'en',
      collection: 'default',
      kind: 'person',
      api_key: @admin.api_key
    )
    expect(response).to be_success
    data = JSON.parse(response.body)

    expect(data['entity']['name']).to eq('Leonardo da Vinci')
    expect(Entity.count).to eq(0)
  end

  it 'should import an item' do
    post(:import,
      id: 'Q762',
      locale: 'en',
      collection: 'default',
      kind: 'person',
      api_key: @admin.api_key
    )
    expect(response).to be_success
    expect(Entity.last.name).to eq('Leonardo da Vinci')
  end

end