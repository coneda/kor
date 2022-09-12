require 'rails_helper'

RSpec.describe Kor::EntityMerger do
  it "should merge entities while preserving the dataset" do
    mona_lisa = Entity.find_by!(name: 'Mona Lisa')
    mona_lisa.update dataset: {'gnd' => '12345', 'google_maps' => 'Am Dornbusch 13, 60315 Frankfurt'}
    other_mona_lisa = FactoryBot.create :mona_lisa, :name => "Mona Liza"

    merged = described_class.new.run(
      :old_ids => [mona_lisa.id, other_mona_lisa.id],
      :attributes => {
        :name => mona_lisa.name
      }
    )

    expect(Entity.count).to eql(7)
    expect(merged.dataset['gnd']).to eql('12345')
    expect(merged.dataset['google_maps']).to eql('Am Dornbusch 13, 60315 Frankfurt')
  end

  it "should preserve synonyms as an array" do
    mona_lisa = Entity.find_by!(name: 'Mona Lisa')
    mona_lisa.update :synonyms => ["La Gioconda"]
    other_mona_lisa = FactoryBot.create :mona_lisa, :name => "Mona Liza", :synonyms => ["La Gioconda"]

    merged = described_class.new.run(
      :old_ids => [mona_lisa.id, other_mona_lisa.id],
      :attributes => {
        :name => mona_lisa.name,
        :synonyms => "La Gioconda"
      }
    )

    expect(Entity.count).to eql(7)
    expect(merged.synonyms).to eq(["La Gioconda"])
  end

  it "should push the merge result to elasticsearch", elastic: true do
    mona_lisa = Entity.find_by!(name: 'Mona Lisa')
    other_mona_lisa = FactoryBot.create :mona_lisa, :name => "Mona Liza"

    merged = described_class.new.run(
      :old_ids => [mona_lisa.id, other_mona_lisa.id],
      :attributes => {name: mona_lisa.name}
    )

    expect(Entity.count).to eql(7)
    expect{
      Kor::Elastic.get merged
    }.not_to raise_error
  end

  it "should not leave old identifiers behind" do
    works = Kind.find_by(name: 'work')
    works.update fields: [
      Field.new(name: 'gnd', show_label: 'GND-ID', is_identifier: true)
    ]
    mona_lisa = Entity.find_by!(name: 'Mona Lisa')
    mona_lisa.update dataset: {'gnd' => '12345'}
    other_mona_lisa = FactoryBot.create :mona_lisa, :name => "Mona Liza"
    merged = described_class.new.run(
      old_ids: [mona_lisa.id, other_mona_lisa.id],
      attributes: {
        name: mona_lisa.name,
        dataset: {'gnd' => '12345'}
      }
    )

    expect(Identifier.count).to eq(2)
    expect(merged.identifiers.first.entity_id).to eq(merged.id)
  end

  it "should transfer relationships to the merged entity" do
    merged = described_class.new.run(
      old_ids: [mona_lisa.id, last_supper.id],
      attributes: {name: 'Mona Lisa'}
    )

    expect(Entity.count).to eq(6)
    expect(DirectedRelationship.count).to eq(14)
    expect(Relationship.count).to eq(7)

    rels = merged.outgoing_relationships
    expect(rels.count).to eq(7)
    expect(rels.by_relation_name('is related to').count).to eq(2) # one to itself
    expect(rels.by_relation_name('has been created by').count).to eq(2)
    expect(rels.by_relation_name('is located in').count).to eq(1)
    expect(rels.by_relation_name('is shown by').count).to eq(2)
  end

  it "should fail the whole transaction when the merge result is invalid" do
    mona_lisa = Entity.find_by!(name: 'Mona Lisa')
    other_mona_lisa = FactoryBot.create :mona_lisa, name: "Mona Liza"

    merged = described_class.new.run(
      old_ids: [mona_lisa.id, other_mona_lisa.id],
      attributes: {name: ''} # produces error
    )

    expect(merged).not_to be_valid
    expect(merged).to be_new_record

    expect(Entity.count).to eq(8)
    expect(DirectedRelationship.count).to eq(14)
    expect(Relationship.count).to eq(7)
  end

  it 'should merge media' do
    a = Entity.media[0]
    b = Entity.media[1]

    described_class.new.run(
      :old_ids => [a.id, b.id],
      :attributes => {
        :medium_id => b.medium_id
      }
    )

    expect(Entity.count).to eql(6)
    expect(Entity.last.medium_id).to eq(b.medium_id)
  end
end
