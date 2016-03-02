require "rails_helper"

describe Kor::Export::MetaData do
  include DataHelper
  
  it "should correctly include relationship properties" do
    FactoryGirl.create :media
    FactoryGirl.create :shows
    FactoryGirl.create :has_created

    default = FactoryGirl.create :default
    admins = FactoryGirl.create :admins
    admin = FactoryGirl.create :admin, :groups => [admins]
    default.grant :view, to: admins
    image = FactoryGirl.create :picture_a
    mona_lisa = FactoryGirl.create :mona_lisa
    leonardo = FactoryGirl.create :leonardo
    
    Relationship.relate_and_save image, 'shows', mona_lisa
    Relationship.relate_and_save leonardo, 'has created', mona_lisa, []

    expect(Relationship.count).to eql(2)

    exporter = described_class.new(admin)
    output = exporter.render_entity Entity.media.first

    expect(output).to match(image.uuid)
    expect(output).to match(mona_lisa.name)
    expect(output).to match(leonardo.name)
  end
  
end
