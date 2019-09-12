require 'rails_helper'

RSpec.describe Fields::Regex do
  it "should serialize it's settings" do
    field = described_class.create(
      kind_id: works.id,
      name: 'trick_id',
      show_label: 'Trick ID',
      settings: {regex: "^(aa|bb|ccc)$"}
    )

    expect(field.reload.settings).to eq(regex: "^(aa|bb|ccc)$")
  end
end
