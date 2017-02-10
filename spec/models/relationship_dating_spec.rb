require 'rails_helper'

describe RelationshipDating do

  it 'should inherit from Dating' do
    expect(subject).to be_a(Dating)
  end

end