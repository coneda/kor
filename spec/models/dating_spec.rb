require 'rails_helper'

RSpec.describe Dating do
  it 'should persist julian dates on updates' do
    dating = EntityDating.create(label: 'Dating', dating_string: '1533')

    expect(dating.from_day).to eq(2_280_987)
    expect(dating.to_day).to eq(2_281_351)

    dating.update dating_string: '1888'
    expect(dating.from_day).to eq(2_410_638)
    expect(dating.to_day).to eq(2_411_003)
  end
end
