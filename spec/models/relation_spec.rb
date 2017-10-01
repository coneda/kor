require 'rails_helper'

describe Relation do
  include DataHelper
  
  before :each do
    Kor.config.update 'app' => {
      'gallery' => {
        'primary_relations' => ['shows'], 
        'secondary_relations' => ['has been created by']
    }}
  end
  
  it "should return the primary and secondary relation names" do
    test_data

    expect(Kor.config['app.gallery.primary_relations']).to eql(['shows'])
    expect(Kor.config['app.gallery.secondary_relations']).to eql(['has been created by'])
  
    expect(Relation.primary_relation_names).to eql(['shows'])
    expect(Relation.secondary_relation_names).to eql(['has been created by'])
  end
  
  it "should return a reverse relation name for a given name" do
    test_data

    expect(Relation.reverse_name_for_name('shows')).to eql("is shown by")
    expect(Relation.reverse_name_for_name('is shown by')).to eql("shows")
  end

  it "should return reverse primary relation names" do
    test_data

    expect(Relation.reverse_primary_relation_names).to eql(['is shown by'])
  end
  
  it "should return all available relation names" do
    test_data

    expect(Relation.available_relation_names.size).to eql(7)
  end
  
  it "should only return relation names available for a given 'from-kind'" do
    test_data

    expect(Relation.available_relation_names(from_ids: @artwork_kind.id).size).to eql(4)
  end

  it "should allow setting a custom uuid on creation" do
    test_data

    relation = FactoryGirl.create :is_located_at, :uuid => "1234"
    expect(relation.uuid).to eq("1234")
  end

  it "should update directed relationships when its name changes" do
    default_setup relationships: true

    expect(DirectedRelationship.where(relation_name: 'has created').count).to eq(2)
    expect(DirectedRelationship.where(relation_name: 'has been created by').count).to eq(2)
    has_created = Relation.where(name: 'has created').first

    has_created.update name: 'has worked on'

    expect(DirectedRelationship.where(relation_name: 'has created').count).to eq(0)
    expect(DirectedRelationship.where(relation_name: 'has been created by').count).to eq(2)
    expect(DirectedRelationship.where(relation_name: 'has worked on').count).to eq(2)

    has_created.update reverse_name: 'has been worked on by'

    expect(DirectedRelationship.where(relation_name: 'has created').count).to eq(0)
    expect(DirectedRelationship.where(relation_name: 'has been created by').count).to eq(0)
    expect(DirectedRelationship.where(relation_name: 'has worked on').count).to eq(2)
    expect(DirectedRelationship.where(relation_name: 'has been worked on by').count).to eq(2)
  end

  it 'should update directed relationships when its symmetry changes' do
    default_setup

    is_equivalent_to = FactoryGirl.create(:is_equivalent_to,
      from_kind_ids: [@works.id, @people.id, @media.id],
      to_kind_ids: [@works.id, @people.id, @media.id]
    )
    Relationship.relate_and_save(@leonardo, 'is equivalent to', @mona_lisa)

    expect(DirectedRelationship.where(relation_name: 'is equivalent to').count).to eq(2)

    is_equivalent_to.update_attributes name: 'is the same as'

    expect(DirectedRelationship.where(relation_name: 'is the same as').count).to eq(1)
    expect(DirectedRelationship.where(relation_name: 'is equivalent to').count).to eq(1)
  end

  it "should get a list of filtered relation names" do
    default_setup

    expect(Relation.available_relation_names).to(
      eq(["has been created by", "has created", "is shown by", "shows"])
    )
    expect(Relation.available_relation_names(from_ids: [])).to(
      eq(["has been created by", "has created", "is shown by", "shows"])
    )
    expect(Relation.available_relation_names(from_ids: nil)).to(
      eq(["has been created by", "has created", "is shown by", "shows"])
    )
    expect(Relation.available_relation_names(from_ids: [], to_ids: [])).to(
      eq(["has been created by", "has created", "is shown by", "shows"])
    )
    expect(Relation.available_relation_names(from_ids: nil, to_ids: nil)).to(
      eq(["has been created by", "has created", "is shown by", "shows"])
    )
    expect(Relation.available_relation_names(from_ids: @media.id)).to(
      eq(['shows'])
    )
    expect(Relation.available_relation_names(from_ids: @works.id)).to(
      eq(["has been created by", "is shown by"])
    )
    expect(Relation.available_relation_names(to_ids: @works.id)).to(
      eq(["has created", "shows"])
    )
  end

end
