require 'rails_helper'

RSpec.describe Kor::SearchResult do
  
  it 'should retrieve items from uuids' do
    mona_lisa = Entity.find_by! name: 'Mona Lisa'
    last_supper = Entity.find_by! name: 'The Last Supper'

    search_result = described_class.new(
      uuids: [mona_lisa.uuid, last_supper.uuid]
    )
    expect(search_result.uuids).to eq([mona_lisa.uuid, last_supper.uuid])
    expect(search_result.records).to eq([mona_lisa, last_supper])

    search_result = described_class.new(
      uuids: [last_supper.uuid, mona_lisa.uuid]
    )
    expect(search_result.uuids).to eq([last_supper.uuid, mona_lisa.uuid])
    expect(search_result.records).to eq([last_supper, mona_lisa])
  end
end