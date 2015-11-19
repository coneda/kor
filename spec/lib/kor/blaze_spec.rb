require 'rails_helper'

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

    expect(Relationship.count).to eq(2)

    blaze = Kor::Blaze.new(u)
    result = blaze.relations_for(b, :include_relationships => true)

    expect(result.count).to eq(2)
    expect(result.first[:relationships].count).to eq(1)
    expect(result.last[:relationships].count).to eq(1)
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
    expect(Relationship.count).to eq(2)
    blaze = Kor::Blaze.new(u)
    result = blaze.relations_for(b, :include_relationships => true)
    expect(result.count).to eq(1)
    expect(result.first[:relationships].count).to eq(2)
    expect(result.first[:relationships][0][:entity_id]).to eq(a.id)
    expect(result.first[:relationships][1][:entity_id]).to eq(c.id)

    Relationship.destroy_all
    expect(Relationship.count).to eq(0)

    Relationship.relate_and_save a, r1.name, b
    Relationship.relate_and_save b, r1.name, c
    Relationship.relate_and_save a, r2.name, b
    Relationship.relate_and_save b, r2.name, c
    expect(Relationship.count).to eq(4)
    blaze = Kor::Blaze.new(u)
    result = blaze.relations_for(b, :include_relationships => true)
    expect(result.count).to eq(1)
    expect(result.first[:relationships].count).to eq(4)
    expect(result.first[:relationships][0][:entity_id]).to eq(a.id)
    expect(result.first[:relationships][1][:entity_id]).to eq(a.id)
    expect(result.first[:relationships][2][:entity_id]).to eq(c.id)
    expect(result.first[:relationships][3][:entity_id]).to eq(c.id)
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

  it "should retrieve related entities" do
    default = FactoryGirl.create :default

    is_part_of = FactoryGirl.create :is_part_of
    has_created = FactoryGirl.create :has_created
    is_sibling_of = FactoryGirl.create :is_sibling_of

    admins = Credential.create :name => "admins"
    admin = FactoryGirl.create :admin, :groups => [admins]
    default.grant :view, :to => admins

    mona_lisa = FactoryGirl.create :mona_lisa
    der_schrei = FactoryGirl.create :der_schrei
    leonardo = FactoryGirl.create :leonardo
    ramirez = FactoryGirl.create :ramirez

    Relationship.relate_and_save leonardo, "has created", mona_lisa
    Relationship.relate_and_save leonardo, "has created", der_schrei
    Relationship.relate_and_save leonardo, "is sibling of", ramirez

    blaze = Kor::Blaze.new(admin)
    expect(blaze.related_entities(mona_lisa).count).to eq(1)
    expect(blaze.related_entities(der_schrei).count).to eq(1)
    expect(blaze.related_entities(leonardo).count).to eq(3)
    expect(blaze.related_entities(ramirez).count).to eq(1)
  end

end