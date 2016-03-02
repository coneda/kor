require 'rails_helper'

describe Kor::EntityMerger do
  include DataHelper
  
  it "should merge entities while preserving the dataset" do
    test_data
    
    mona_lisa = Entity.find_by_name('Mona Lisa')
    mona_lisa.dataset = {'gnd' => '12345', 'google_maps' => 'Am Dornbusch 13, 60315 Frankfurt'}
    
    merged = described_class.new.run(:old_ids => Entity.all.map{|e| e.id},
      :attributes => {
        :name => mona_lisa.name,
        :dataset => {
          'gnd' => '12345'
        }
      }
    )
    
    expect(Entity.count).to eql(1)
    expect(merged.dataset['gnd']).to eql('12345')
  end

  it "should preserve synonyms as an array" do
    mona_lisa = FactoryGirl.create :mona_lisa, :synonyms => ["La Gioconda"]
    other_mona_lisa = FactoryGirl.create :mona_lisa, :name => "Mona Liza", :synonyms => ["La Gioconda"]

    merged = described_class.new.run(:old_ids => Entity.all.map{|e| e.id},
      :attributes => {
        :name => mona_lisa.name,
        :synonyms => "La Gioconda"
      }
    )
    
    expect(Entity.count).to eql(1)
    expect(merged.synonyms).to eq(["La Gioconda"])
  end

  it "should push the merge result to elasticsearch", elastic: true do
    mona_lisa = FactoryGirl.create :mona_lisa
    other_mona_lisa = FactoryGirl.create :mona_lisa, :name => "Mona Liza"

    expect(Kor::Elastic).to receive(:drop).twice.and_call_original
    expect(Kor::Elastic).to receive(:index).and_call_original
    merged = described_class.new.run(:old_ids => Entity.all.map{|e| e.id},
      :attributes => {name: mona_lisa.name}
    )
    
    expect(Entity.count).to eql(1)
    expect {
      Kor::Elastic.get merged
    }.not_to raise_error
  end

  it "should not leave old identifiers behind" do
    artworks = FactoryGirl.create :works, fields: [
      Field.new(name: 'gnd', show_label: 'GND-ID', is_identifier: true)
    ]

    mona_lisa = FactoryGirl.create :mona_lisa, dataset: {'gnd' => '12345'}
    other_mona_lisa = FactoryGirl.create :mona_lisa, :name => "Mona Liza"
    merged = described_class.new.run(
      old_ids: [mona_lisa.id, other_mona_lisa.id],
      attributes: {
        name: mona_lisa.name,
        dataset: {'gnd' => '12345'}
      }
    )

    expect(Identifier.count).to eq(1)
    expect(Identifier.first.entity_id).to eq(merged.id)
  end

end
