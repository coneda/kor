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
    FactoryGirl.create :media
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
    FactoryGirl.create :media
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

  it "should transfer relationships to the merged entity" do
    Delayed::Worker.delay_jobs = false

    admins = FactoryGirl.create :admins
    admin = FactoryGirl.create :admin, groups: [admins]
    default = FactoryGirl.create :default
    Kor::Auth.grant default, :view, to: [admins]
    FactoryGirl.create :media
    mona_lisa = FactoryGirl.create :mona_lisa, :name => 'Mona Lysa'
    other_mona_lisa = FactoryGirl.create :mona_lisa, name: "Mona Liza"
    third_mona_lisa = FactoryGirl.create :mona_lisa, name: "Mona Lica"
    leonardo = FactoryGirl.create :leonardo
    institution = FactoryGirl.create :institution
    FactoryGirl.create :is_located_at
    FactoryGirl.create :has_created
    Relationship.relate_and_save mona_lisa, 'is located at', institution
    Relationship.relate_and_save other_mona_lisa, 'has been created by', leonardo
    Relationship.relate_and_save third_mona_lisa, 'has been created by', leonardo

    merged = described_class.new.run(
      old_ids: [mona_lisa.id, other_mona_lisa.id, third_mona_lisa.id],
      attributes: {name: 'Mona Lisa'}
    )

    expect(Entity.count).to eq(3)
    expect(DirectedRelationship.count).to eq(6)
    expect(Relationship.count).to eq(3)
    expect(merged.in_rels.count).to eq(2)
    expect(merged.in_rels.first.from).to eq(leonardo)
    expect(merged.in_rels.last.from).to eq(leonardo)
    expect(merged.out_rels.count).to eq(1)
    expect(merged.out_rels.first.to).to eq(institution)

    expect(merged.incoming_relationships.count).to eq(3)
    expect(merged.outgoing_relationships.count).to eq(3)

    expect(merged.relation_counts(admin)).to eq(
      'is located at' => 1,
      'has been created by' => 2,
    )
  end

  it "should fail the whole transaction when the merge result is invalid" do
    Delayed::Worker.delay_jobs = false

    admins = FactoryGirl.create :admins
    admin = FactoryGirl.create :admin, groups: [admins]
    default = FactoryGirl.create :default
    Kor::Auth.grant default, :view, to: [admins]
    FactoryGirl.create :media
    conflicting_mona_lisa = FactoryGirl.create :mona_lisa, name: "Mona Lisa"
    mona_lisa = FactoryGirl.create :mona_lisa, :name => 'Mona Lysa'
    other_mona_lisa = FactoryGirl.create :mona_lisa, name: "Mona Liza"
    third_mona_lisa = FactoryGirl.create :mona_lisa, name: "Mona Lica"
    leonardo = FactoryGirl.create :leonardo
    institution = FactoryGirl.create :institution
    FactoryGirl.create :is_located_at
    FactoryGirl.create :has_created
    Relationship.relate_and_save mona_lisa, 'is located at', institution
    Relationship.relate_and_save other_mona_lisa, 'has been created by', leonardo
    Relationship.relate_and_save third_mona_lisa, 'has been created by', leonardo

    merged = described_class.new.run(
      old_ids: [mona_lisa.id, other_mona_lisa.id, third_mona_lisa.id],
      attributes: {name: conflicting_mona_lisa.name}
    )

    expect(merged).not_to be_valid
    expect(merged).to be_new_record

    expect(Entity.count).to eq(6)
    expect(DirectedRelationship.count).to eq(6)
    expect(Relationship.count).to eq(3)
  end

end
