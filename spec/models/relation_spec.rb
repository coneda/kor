require 'spec_helper'

describe Relation do
  include DataHelper
  
  before :each do
    test_data
    
    Kor.config.update 'app' => {
      'gallery' => {
        'primary_relations' => ['stellt dar'], 
        'secondary_relations' => ['wurde erschaffen von']
    }}
  end
  
  it "should return the primary and secondary relation names" do
    Kor.config['app.gallery.primary_relations'].should eql(['stellt dar'])
    Kor.config['app.gallery.secondary_relations'].should eql(['wurde erschaffen von'])
  
    Relation.primary_relation_names.should eql(['stellt dar'])
    Relation.secondary_relation_names.should eql(['wurde erschaffen von'])
  end
  
  it "should return a reverse relation name for a given name" do
    Relation.reverse_name_for_name('stellt dar').should eql("wird dargestellt von")
    Relation.reverse_name_for_name('wird dargestellt von').should eql("stellt dar")
  end

  it "should return reverse primary relation names" do
    Relation.reverse_primary_relation_names.should eql([ 'wird dargestellt von' ])
  end
  
  it "should return all available relation names" do
    Relation.available_relation_names.size.should eql(7)
  end
  
  it "should only return relation names available for a given 'from-kind'" do
    Relation.available_relation_names(@artwork_kind.id).size.should eql(4)
  end
end
