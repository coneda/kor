require 'rails_helper'

RSpec.describe InplaceController, :type => :controller do

  it "should not allow tagging to guests when the collection doesn't allow it" do
    guest = FactoryGirl.create :guest
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(guest)
    works = FactoryGirl.create :works
    mona_lisa = FactoryGirl.create :mona_lisa

    post :update_entity_tags, :entity_id => mona_lisa.id, :value => "red, fox, brown, river"
    expect(response.status).to be(403)
  end

  it "should allow tagging to guests when the collection allows it" do
    guests = FactoryGirl.create :guests
    guest = FactoryGirl.create :guest, :groups => [guests]
    default = FactoryGirl.create :default

    Grant.create :collection => default, :credential => guests, :policy => "tagging"

    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(guest)
    works = FactoryGirl.create :works
    mona_lisa = FactoryGirl.create :mona_lisa

    post :update_entity_tags, :entity_id => mona_lisa.id, :value => "red, fox, brown, river"
    expect(response.status).to be(200)
  end

end