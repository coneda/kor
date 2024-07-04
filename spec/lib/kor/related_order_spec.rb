require 'rails_helper'

RSpec.describe Kor::RelatedOrder do
  it "should not apply custom order by default" do
    count = DirectedRelationship.where('position != 0').count
    expect(count).to eq(0)
  end

  it 'should apply a custom order when changing a position' do
    FactoryBot.create(:picture_c)
    Relationship.relate_and_save picture_c, 'shows', mona_lisa
    rels = mona_lisa.
      outgoing_relationships.
      where(relation_name: 'is shown by').
      order_by_position_and_name
    expect(rels.map{|r| r.position}).to eq([0, 0])
    expect(rels[1].to_id).to eq(picture_c.id)

    Kor::RelatedOrder.move_to(rels[1], 1)
    rels.reload
    expect(rels.map{|r| r.position}).to eq([1, 2])
    expect(rels[0].to_id).to eq(picture_c.id)

    Kor::RelatedOrder.new(mona_lisa.id, 'is shown by').remove_custom!
    rels.reload
    expect(rels.map{|r| r.position}).to eq([0, 0])
    expect(rels[1].to_id).to eq(picture_c.id)
  end
end
