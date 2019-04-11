require "rails_helper"

describe IdentifiersController, :type => :controller do
  render_views

  it "should resolve an entity by id or uuid" do
    people = FactoryGirl.create :people, :fields => [
      Field.new(:name => "gnd_id", :is_identifier => true, :show_label => "GND-ID")
    ]
    leonardo = FactoryGirl.create :leonardo, :dataset => {"gnd_id" => "1234"}

    get :resolve, :id => leonardo.id
    expect(response).to redirect_to("/blaze#/entities/#{leonardo.id}")

    get :resolve, :id => leonardo.uuid
    expect(response).to redirect_to("/blaze#/entities/#{leonardo.id}")
  end

  it "should resolve an entity when the identifier type is known" do
    people = FactoryGirl.create :people, :fields => [
      Field.new(:name => "gnd_id", :is_identifier => true, :show_label => "GND-ID")
    ]
    leonardo = FactoryGirl.create :leonardo, :dataset => {"gnd_id" => "1234"}

    get :resolve, :kind => "gnd_id", :id => "1234"
    expect(response).to redirect_to("/blaze#/entities/#{leonardo.id}")
  end

  it "should resolve an entity when the identifier type is not known" do
    people = FactoryGirl.create :people, :fields => [
      Field.new(:name => "gnd_id", :is_identifier => true, :show_label => "GND-ID")
    ]
    leonardo = FactoryGirl.create :leonardo, :dataset => {"gnd_id" => "1234"}

    get :resolve, :id => "1234"
    expect(response).to redirect_to("/blaze#/entities/#{leonardo.id}")
  end

  it 'should resolve an entity by a identifier value including a dot' do
    people = FactoryGirl.create :people, :fields => [
      Field.new(:name => "gnd_id", :is_identifier => true, :show_label => "GND-ID")
    ]
    leonardo = FactoryGirl.create :leonardo, :dataset => {"gnd_id" => "BMN_2002.33a-b_view1_bw"}

    get :resolve, kind: 'gnd_id', id: "BMN_2002.33a-b_view1_bw"
    expect(response).to redirect_to("/blaze#/entities/#{leonardo.id}")
  end

  it 'should resolve to a 404 page when the identifier is not found' do
    get :resolve, kind: 'x', id: "1234"
    expect(response).to be_a_not_found
  end
end