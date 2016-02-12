require 'rails_helper'

describe Relation do
  include DataHelper
  
  before :each do
    test_data
    
    Kor.config.update 'app' => {
      'gallery' => {
        'primary_relations' => ['shows'], 
        'secondary_relations' => ['has been created by']
    }}
  end
  
  it "should return the primary and secondary relation names" do
    expect(Kor.config['app.gallery.primary_relations']).to eql(['shows'])
    expect(Kor.config['app.gallery.secondary_relations']).to eql(['has been created by'])
  
    expect(Relation.primary_relation_names).to eql(['shows'])
    expect(Relation.secondary_relation_names).to eql(['has been created by'])
  end
  
  it "should return a reverse relation name for a given name" do
    expect(Relation.reverse_name_for_name('shows')).to eql("is shown by")
    expect(Relation.reverse_name_for_name('is shown by')).to eql("shows")
  end

  it "should return reverse primary relation names" do
    expect(Relation.reverse_primary_relation_names).to eql(['is shown by'])
  end
  
  it "should return all available relation names" do
    expect(Relation.available_relation_names.size).to eql(7)
  end
  
  it "should only return relation names available for a given 'from-kind'" do
    expect(Relation.available_relation_names(@artwork_kind.id).size).to eql(4)
  end
end
