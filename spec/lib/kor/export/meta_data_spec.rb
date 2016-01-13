require "rails_helper"

describe Kor::Export::MetaData do
  include DataHelper
  
  it "should correctly include relationship properties" do
    test_data_for_auth
    test_kinds
    test_relations
    test_entities
    
    image = FactoryGirl.create :image_a
    mona_lisa = Entity.find_by_name('Mona Lisa')
    leonardo = FactoryGirl.create :leonardo
    
    Relationship.relate_and_save image, 'shows', mona_lisa
    Relationship.relate_and_save leonardo, 'has created', mona_lisa, []
    
    expect(Relationship.count).to eql(2)
    
    expect {
      exporter = described_class.new('simple')
      exporter.render_entity Entity.media.first
    }.not_to raise_error
  end
  
end
