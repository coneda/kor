require 'rails_helper'

RSpec.describe Relationship do
  it "should be creatable and updatable with a relation name" do
    relationship = Relationship.create(
      from: leonardo,
      relation_name: 'has created',
      to: mona_lisa
    )

    expect(relationship.from_id).to eq(leonardo.id)
    expect(relationship.to_id).to eq(mona_lisa.id)

    relationship = Relationship.create(
      from: mona_lisa,
      relation_name: 'has been created by',
      to: leonardo
    )

    expect(relationship.from_id).to eq(leonardo.id)
    expect(relationship.to_id).to eq(mona_lisa.id)

    expect{
      relationship.update(
        from: leonardo,
        relation_name: 'has been created by',
        to: mona_lisa
      )
    }.to raise_error(Kor::Exception)

    expect(relationship.from_id).to eq(leonardo.id)
    expect(relationship.to_id).to eq(mona_lisa.id)

    expect(Relationship.count).to eq(9)
  end

  it "should accept nested attributes for entity datings" do
    leonardo = FactoryBot.create :leonardo
    mona_lisa = FactoryBot.create :mona_lisa
    has_created = FactoryBot.create :has_created, from_kind: leonardo.kind, to_kind: mona_lisa.kind

    relationship = Relationship.create(
      relation: has_created,
      from: leonardo,
      to: mona_lisa,
      datings_attributes: [
        {label: 'erste Phase', dating_string: '11. Jahrhundert'},
        {label: 'zweite Phase', dating_string: '13. Jahrhundert'}
      ]
    )

    expect(relationship.datings.count).to eq(2)
  end

  it "should search by dating" do
    leonardo = FactoryBot.create :leonardo
    mona_lisa = FactoryBot.create :mona_lisa
    has_created = FactoryBot.create :has_created, from_kind: leonardo.kind, to_kind: mona_lisa.kind

    Relationship.create(
      relation: has_created,
      from: leonardo,
      to: mona_lisa,
      datings_attributes: [
        {label: 'erste Phase', dating_string: '1888'},
        {label: 'zweite Phase', dating_string: '1890'},
        {label: 'dritte Phase', dating_string: '1912 bis 1915'},
      ]
    )

    expect(Relationship.dated_in("1534").count).to be_zero
    expect(Relationship.dated_in("1999").count).to be_zero
    expect(Relationship.dated_in("1890").count).to eql(1)
    expect(Relationship.dated_in("1850 bis 1950").count).to eq(1)
  end

  it 'should be (manually) validatable before saving' do
    relationship = Relationship.relate(leonardo.id, 'has created', mona_lisa.id)
    expect(relationship.valid?).to be(true)
    expect(relationship.save).to be(true)
  end

  it 'should validate without side effects' do
    relationship = Relationship.relate(leonardo.id, 'has created', mona_lisa.id)
    relationship.valid?
    expect(relationship.valid?).to be_truthy

    relationship = Relationship.relate(mona_lisa.id, 'has been created by', leonardo.id)
    relationship.valid?
    expect(relationship.valid?).to be_truthy
  end

  it 'should reorder directed_relationships when destroyed' do
    FactoryBot.create(:picture_c)
    Relationship.relate_and_save picture_c, 'shows', mona_lisa

    rels = mona_lisa.outgoing_relationships.where(relation_name: 'is shown by')
    Kor::RelatedOrder.move_to(rels[1], 1)

    rels.reload
    rels[0].relationship.destroy

    rels.reload
    expect(rels.size).to eq(1)
    expect(rels[0].position).to eq(1)
  end
end
