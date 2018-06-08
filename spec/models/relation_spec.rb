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

    relation = FactoryGirl.create(
      :is_located_at, :uuid => "65d89594-4baa-487c-ae77-78f31940cc03",
      from_kind: @person_kind,
      to_kind: @person_kind
    )
    expect(relation.uuid).to eq("65d89594-4baa-487c-ae77-78f31940cc03")
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
      from_kind_id: @works.id,
      to_kind_id: @works.id
    )
    Relationship.relate_and_save(@last_supper, 'is equivalent to', @mona_lisa)

    expect(Relationship.count).to eq(1)
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

  it 'should not permit to be more restrictive on endpoints than the parent' do
    people = FactoryGirl.create(:people)
    artists = FactoryGirl.create(:kind, name: 'artist', plural_name: 'artists', parents: [people])
    artworks = FactoryGirl.create(:kind, name: 'artwork', plural_name: 'artworks')
    paintings = FactoryGirl.create(:kind, name: 'painting', plural_name: 'paintings', parents: [artworks])
    metaphors = FactoryGirl.create(:kind, name: 'metaphor', plural_name: 'metaphors')
    has_created = FactoryGirl.create(:has_created,
      from_kind: people,
      to_kind: artworks
    )
    has_painted = FactoryGirl.create(:relation,
      name: 'has painted',
      reverse_name: 'has been painted by',
      from_kind: artists,
      to_kind: metaphors
    )

    has_painted.parents = [has_created]
    expect(has_painted.valid?).to be_falsey
    expect(has_painted.errors.full_messages).to eq(["permitted type (to) cannot allow more endpoints than its ancestors"])

    has_painted.to_kind = paintings
    expect(has_painted.valid?).to be_truthy
  end

  it 'should save the schema as nil when an empty string is given' do
    default_setup

    @relation = Relation.first
    @relation.update schema: 'something'
    expect(@relation.reload.schema).to eq('something')
    @relation.update schema: ''
    expect(@relation.reload.schema).to eq(nil)
    @relation.update schema: nil
    expect(@relation.reload.schema).to eq(nil)
  end

end
