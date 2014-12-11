require 'spec_helper'

describe Kor::Blaze do

  it "should gather relationships in both directions" do
    k = FactoryGirl.create :works
    r = FactoryGirl.create :is_part_of

    g = Credential.create :name => "admins"
    u = FactoryGirl.create :admin
    u.groups << g

    a = FactoryGirl.create :mona_lisa, :kind => k
    b = FactoryGirl.create :der_schrei, :kind => k
    c = FactoryGirl.create :ramirez, :kind => k

    Collection.first.grant :view, :to => g

    Relationship.relate_and_save a, r.name, b
    Relationship.relate_and_save b, r.name, c

    Relationship.count.should == 2

    blaze = Kor::Blaze.new(u)
    result = blaze.relations_for(b, :include_relationships => true)

    result.count.should == 2
    result.first[:relationships].count.should == 1
    result.last[:relationships].count.should == 1
  end

  it "should gather symmetric relationships just once in both directions" do
    k = FactoryGirl.create :works
    r1 = FactoryGirl.create :relation
    r2 = FactoryGirl.create :relation

    g = Credential.create :name => "admins"
    u = FactoryGirl.create :admin
    u.groups << g

    a = FactoryGirl.create :mona_lisa, :kind => k
    b = FactoryGirl.create :der_schrei, :kind => k
    c = FactoryGirl.create :ramirez, :kind => k

    Collection.first.grant :view, :to => g

    Relationship.relate_and_save a, r1.name, b
    Relationship.relate_and_save b, r1.name, c
    Relationship.count.should == 2
    blaze = Kor::Blaze.new(u)
    result = blaze.relations_for(b, :include_relationships => true)
    result.count.should == 1
    result.first[:relationships].count.should == 2
    result.first[:relationships][0][:entity_id].should == a.id
    result.first[:relationships][1][:entity_id].should == c.id

    Relationship.destroy_all
    Relationship.count.should == 0

    Relationship.relate_and_save a, r1.name, b
    Relationship.relate_and_save b, r1.name, c
    Relationship.relate_and_save a, r2.name, b
    Relationship.relate_and_save b, r2.name, c
    Relationship.count.should == 4
    blaze = Kor::Blaze.new(u)
    result = blaze.relations_for(b, :include_relationships => true)
    result.count.should == 1
    result.first[:relationships].count.should == 4
    result.first[:relationships][0][:entity_id].should == a.id
    result.first[:relationships][1][:entity_id].should == a.id
    result.first[:relationships][2][:entity_id].should == c.id
    result.first[:relationships][3][:entity_id].should == c.id
  end

  it "should not show media previews for unauthorized media entities" do
    default = FactoryGirl.create :default
    media = FactoryGirl.create :media
    works = FactoryGirl.create :works
    people = FactoryGirl.create :people
    medium = FactoryGirl.create :image_a, :collection => FactoryGirl.create(:private)
    mona_lisa = FactoryGirl.create :mona_lisa
    person = FactoryGirl.create :jack
    FactoryGirl.create :shows
    FactoryGirl.create :has_created
    Relationship.relate_and_save(medium, 'shows', mona_lisa)
    Relationship.relate_and_save(mona_lisa, 'has been created by', person)
    admins = FactoryGirl.create :admins
    Grant.create :credential => admins, :collection => default, :policy => "view"
    FactoryGirl.create :admin, :groups => [admins]

    blaze = Kor::Blaze.new(User.admin)
    expect(blaze.relations_for(mona_lisa).first[:name]).to eq("has been created by")
    expect(blaze.relations_for mona_lisa, :media => true).to be_empty
  end

end