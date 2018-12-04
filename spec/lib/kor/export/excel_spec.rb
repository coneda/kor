require "rails_helper"

RSpec.describe Kor::Export::Excel do
  it "should export 3 entities" do
    Kor::Export::Excel.new("#{Rails.root}/tmp/export_spec").run
    book = Spreadsheet.open("#{Rails.root}/tmp/export_spec/entities.0001.xls")
    sheet = book.worksheet 0

    expect(sheet.rows.count).to eq(8)
    expect(sheet[2, 0]).to eq(mona_lisa.id)
    expect(sheet[3, 1]).to eq(last_supper.uuid)
    expect(sheet[1, 3]).to eq(leonardo.name)
  end

  it "should only export the given collections" do
    Kor::Export::Excel.new("#{Rails.root}/tmp/export_spec", :collection_id => [priv.id]).run
    book = Spreadsheet.open("#{Rails.root}/tmp/export_spec/entities.0001.xls")
    sheet = book.worksheet 0

    expect(sheet.rows.count).to eq(3)
  end

  it "should only export the given kinds" do
    Kor::Export::Excel.new("#{Rails.root}/tmp/export_spec", :kind_id => leonardo.kind_id).run
    book = Spreadsheet.open("#{Rails.root}/tmp/export_spec/entities.0001.xls")
    sheet = book.worksheet 0

    expect(sheet.rows.count).to eq(2)
  end

  it "should export only utc" do
    ts = leonardo.created_at

    Kor::Export::Excel.new("#{Rails.root}/tmp/export_spec").run
    book = Spreadsheet.open("#{Rails.root}/tmp/export_spec/entities.0001.xls")
    sheet = book.worksheet 0

    expect(sheet.rows[1][10]).to be_utc
    expect(sheet.rows[1][10].to_f).to be_within(1.5).of(ts.to_f)
  end
end