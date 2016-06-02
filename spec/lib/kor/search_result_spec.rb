require 'rails_helper'

describe Kor::SearchResult do
  
  it 'should retrieve items from uuids' do
    FactoryGirl.create :media
    @works = FactoryGirl.create :works
    @mona_lisa = FactoryGirl.create :mona_lisa
    @der_schrei = FactoryGirl.create :der_schrei

    search_result = described_class.new(
      uuids: [@mona_lisa.uuid, @der_schrei.uuid]
    )
    expect(search_result.uuids).to eq([@mona_lisa.uuid, @der_schrei.uuid])
    expect(search_result.records).to eq([@mona_lisa, @der_schrei])

    search_result = described_class.new(
      uuids: [@der_schrei.uuid, @mona_lisa.uuid]
    )
    expect(search_result.uuids).to eq([@der_schrei.uuid, @mona_lisa.uuid])
    expect(search_result.records).to eq([@der_schrei, @mona_lisa])
  end

end