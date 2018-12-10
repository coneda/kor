require 'rails_helper'

RSpec.describe AuthorityGroup do
  it 'should add entities via the << method' do
    seminar.entities << mona_lisa
    expect(lecture.reload.entities.size).to eql(1)
  end
end
