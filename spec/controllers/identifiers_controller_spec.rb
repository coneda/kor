require "rails_helper"

describe IdentifiersController, :type => :controller do

  it "should resolve an entity by id or uuid" do
    people = FactoryGirl.create :people, :fields => [
      Field.new(:name => "gnd_id", :is_identifier => true, :show_label => "GND-ID")
    ]
    leonardo = FactoryGirl.create :leonardo, :dataset => {"gnd_id" => "1234"}

    get :resolve, :id => leonardo.id
    expect(response).to redirect_to(entity_path leonardo)

    get :resolve, :id => leonardo.uuid
    expect(response).to redirect_to(entity_path leonardo)
  end

  it "should resolve an entity when the identifier type is known" do
    people = FactoryGirl.create :people, :fields => [
      Field.new(:name => "gnd_id", :is_identifier => true, :show_label => "GND-ID")
    ]
    leonardo = FactoryGirl.create :leonardo, :dataset => {"gnd_id" => "1234"}

    get :resolve, :kind => "gnd_id", :id => "1234"
    expect(response).to redirect_to(entity_path leonardo)
  end

  it "should resolve an entity when the identifier type is not known" do
    people = FactoryGirl.create :people, :fields => [
      Field.new(:name => "gnd_id", :is_identifier => true, :show_label => "GND-ID")
    ]
    leonardo = FactoryGirl.create :leonardo, :dataset => {"gnd_id" => "1234"}

    get :resolve, :id => "1234"
    expect(response).to redirect_to(entity_path leonardo)
  end

end