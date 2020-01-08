require 'rails_helper'

RSpec.describe Dating do
  it 'should persist julian dates on updates' do
    dating = EntityDating.create(label: 'Dating', dating_string: '1533')
    
    expect(dating.from_day).to eq(2280987)
    expect(dating.to_day).to eq(2281351)

    dating.update_attributes dating_string: '1888'
    expect(dating.from_day).to eq(2410638)
    expect(dating.to_day).to eq(2411003)
  end
end
