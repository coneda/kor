require File.dirname(__FILE__) + '/../../spec_helper'

describe Export::MetaDataProfile do
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
    
    Relationship.count.should eql(2)
    
    lambda {
      exporter = Export::MetaDataProfile.new('simple')
      exporter.render_entity Entity.media.first
    }.should_not raise_error
  end
  
end
