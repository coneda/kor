require 'rails_helper'

RSpec.describe RelationshipDating do

  it 'should inherit from Dating' do
    expect(subject).to be_a(Dating)
  end

end