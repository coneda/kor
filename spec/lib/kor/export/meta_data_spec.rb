require "rails_helper"

RSpec.describe Kor::Export::MetaData do
  it "should correctly include relationship properties" do
    mona_lisa = Entity.find_by! name: 'Mona Lisa'
    leonardo = Entity.find_by! name: 'Leonardo'
    image = Entity.media.first
    exporter = described_class.new(User.admin)
    output = exporter.render_entity image

    expect(output).to match(image.uuid)
    expect(output).to match(mona_lisa.name)
    expect(output).to match(leonardo.name)
  end
end
