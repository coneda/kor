require 'rails_helper'

RSpec.describe Kor::EntityMerger do
  it "should merge entities while preserving the dataset" do
    mona_lisa = Entity.find_by!(name: 'Mona Lisa')
    mona_lisa.update dataset: {'gnd' => '12345', 'google_maps' => 'Am Dornbusch 13, 60315 Frankfurt'}
    other_mona_lisa = FactoryGirl.create :mona_lisa, :name => "Mona Liza"

    merged = described_class.new.run(
      :old_ids => [mona_lisa.id, other_mona_lisa.id],
      :attributes => {
        :name => mona_lisa.name
      }
    )
    
    expect(Entity.count).to eql(4)
    expect(merged.dataset['gnd']).to eql('12345')
    expect(merged.dataset['google_maps']).to eql('Am Dornbusch 13, 60315 Frankfurt')
  end

  it "should preserve synonyms as an array" do
    mona_lisa = Entity.find_by!(name: 'Mona Lisa')
    mona_lisa.update :synonyms => ["La Gioconda"]
    other_mona_lisa = FactoryGirl.create :mona_lisa, :name => "Mona Liza", :synonyms => ["La Gioconda"]

    merged = described_class.new.run(
      :old_ids => [mona_lisa.id, other_mona_lisa.id],
      :attributes => {
        :name => mona_lisa.name,
        :synonyms => "La Gioconda"
      }
    )
    
    expect(Entity.count).to eql(4)
    expect(merged.synonyms).to eq(["La Gioconda"])
  end

  it "should push the merge result to elasticsearch", elastic: true do
    mona_lisa = Entity.find_by!(name: 'Mona Lisa')
    other_mona_lisa = FactoryGirl.create :mona_lisa, :name => "Mona Liza"

    expect(Kor::Elastic).to receive(:drop).twice.and_call_original
    expect(Kor::Elastic).to receive(:index).and_call_original

    merged = described_class.new.run(
      :old_ids => [mona_lisa.id, other_mona_lisa.id],
      :attributes => {name: mona_lisa.name}
    )
    
    expect(Entity.count).to eql(4)
    expect {
      Kor::Elastic.get merged
    }.not_to raise_error
  end

  it "should not leave old identifiers behind" do
    works = Kind.find_by(name: 'work')
    works.update fields: [
      Field.new(name: 'gnd', show_label: 'GND-ID', is_identifier: true)
    ]
    mona_lisa = Entity.find_by!(name: 'Mona Lisa')
    mona_lisa.update_attributes dataset: {'gnd' => '12345'}
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

  it "should transfer relationships to the merged entity" do
    Delayed::Worker.delay_jobs = false

    admin = User.admin
    mona_lisa = Entity.find_by!(name: 'Mona Lisa')
    last_supper = Entity.find_by!(name: 'The Last Supper')
    leonardo = Entity.find_by!(name: 'Leonardo da Vinci')

    merged = described_class.new.run(
      old_ids: [mona_lisa.id, last_supper.id],
      attributes: {name: 'Mona Lisa'}
    )

    expect(Entity.count).to eq(3)
    expect(DirectedRelationship.count).to eq(4)
    expect(Relationship.count).to eq(2)
    expect(merged.in_rels.count).to eq(2)
    expect(merged.in_rels.first.from).to eq(leonardo)
    expect(merged.in_rels.last.from).to eq(leonardo)
    expect(merged.out_rels.count).to eq(0)

    expect(merged.incoming_relationships.count).to eq(2)
    expect(merged.outgoing_relationships.count).to eq(2)

    expect(merged.relation_counts(admin)).to eq(
      'has been created by' => 2,
    )
  end

  it "should fail the whole transaction when the merge result is invalid" do
    Delayed::Worker.delay_jobs = false

    mona_lisa = Entity.find_by!(name: 'Mona Lisa')
    other_mona_lisa = FactoryGirl.create :mona_lisa, name: "Mona Liza"

    merged = described_class.new.run(
      old_ids: [mona_lisa.id, other_mona_lisa.id],
      attributes: {name: ''} # produces error
    )

    expect(merged).not_to be_valid
    expect(merged).to be_new_record

    expect(Entity.count).to eq(5)
    expect(DirectedRelationship.count).to eq(4)
    expect(Relationship.count).to eq(2)
  end

  it 'should merge media' do
    Delayed::Worker.delay_jobs = false

    a = FactoryGirl.create :picture_a
    b = FactoryGirl.create :picture_b

    merged = described_class.new.run(
      :old_ids => [a.id, b.id],
      :attributes => {
        :medium_id => b.medium_id
      }
    )

    expect(Entity.count).to eql(5)
    expect(Entity.last.medium_id).to eq(b.medium_id)
  end

  it 'should use soft-delete for merged entities'

end
