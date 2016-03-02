require 'rails_helper'

describe Relationship do

  it "should be creatable and updatable with a relation name" do
    FactoryGirl.create :has_created
    mona_lisa = FactoryGirl.create :mona_lisa
    leonardo = FactoryGirl.create :leonardo

    relationship = Relationship.create(
      from: leonardo,
      relation_name: 'has created',
      to: mona_lisa
    )

    expect(relationship.from_id).to eq(leonardo.id)
    expect(relationship.relation.name).to eq('has created')
    expect(relationship.to_id).to eq(mona_lisa.id)

    relationship = Relationship.create(
      from: mona_lisa,
      relation_name: 'has been created by',
      to: leonardo
    )

    expect(relationship.from_id).to eq(leonardo.id)
    expect(relationship.relation.name).to eq('has created')
    expect(relationship.to_id).to eq(mona_lisa.id)

    relationship.update_attributes(
      from: leonardo,
      relation_name: 'has been created by',
      to: mona_lisa
    )

    expect(relationship.from_id).to eq(mona_lisa.id)
    expect(relationship.relation.name).to eq('has created')
    expect(relationship.to_id).to eq(leonardo.id)

    expect(Relationship.count).to eq(2)
  end

end