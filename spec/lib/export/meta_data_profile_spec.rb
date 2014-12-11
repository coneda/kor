require File.dirname(__FILE__) + '/../../spec_helper'

describe Export::MetaDataProfile do
  include DataHelper
  
  it "should correctly include relationship properties" do
    test_data_for_auth
    test_kinds
    test_relations
    test_entities
    
    image = Kind.medium_kind.entities.make(:medium_attributes => {:document => File.open("#{Rails.root}/spec/fixtures/image_a.jpg")})
    mona_lisa = Entity.find_by_name('Mona Lisa')
    leonardo = Kind.find_by_name('Person').entities.make(:name => 'Leonardo')
    
    Relationship.relate_and_save image, 'stellt dar', mona_lisa
    Relationship.relate_and_save leonardo, 'hat erschaffen', mona_lisa, []
    
    Relationship.count.should eql(2)
    
    lambda {
      exporter = Export::MetaDataProfile.new('simple')
      exporter.render_entity Entity.media.first
    }.should_not raise_error
  end
  
end
