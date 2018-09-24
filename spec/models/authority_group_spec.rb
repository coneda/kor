require 'rails_helper'

RSpec.describe AuthorityGroup do
  include DataHelper
  
  it "should add entities via the << method" do
    group = AuthorityGroup.find_by_name('An authority group')
    entity = Entity.find_by_name('Mona Lisa')
    
    group.entities << entity
    expect(AuthorityGroup.find_by_name('An authority group').entities.size).to eql(1)
  end
  
end
