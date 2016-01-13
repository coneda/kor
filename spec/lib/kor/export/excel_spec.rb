require "rails_helper"

describe Kor::Export::Excel do

  it "should export 3 entities" do
    mona_lisa = FactoryGirl.create :mona_lisa
    der_schrei = FactoryGirl.create :der_schrei
    leonardo = FactoryGirl.create :leonardo

    Kor::Export::Excel.new("#{Rails.root}/tmp/export_spec").run

    book = Spreadsheet.open("#{Rails.root}/tmp/export_spec/entities.0001.xls")
    sheet = book.worksheet 0

    expect(sheet.rows.count).to eq(4)

    expect(sheet[1, 0]).to eq(mona_lisa.id)
    expect(sheet[2, 1]).to eq(der_schrei.uuid)
    expect(sheet[3, 3]).to eq(leonardo.name)
  end

  it "should only export the given collections" do
    priv = FactoryGirl.create :private
    mona_lisa = FactoryGirl.create :mona_lisa
    der_schrei = FactoryGirl.create :der_schrei, :collection => priv

    Kor::Export::Excel.new("#{Rails.root}/tmp/export_spec", :collection_id => [priv.id]).run

    book = Spreadsheet.open("#{Rails.root}/tmp/export_spec/entities.0001.xls")
    sheet = book.worksheet 0

    expect(sheet.rows.count).to eq(2)
  end

  it "should only export the given kinds" do
    mona_lisa = FactoryGirl.create :mona_lisa
    leonardo = FactoryGirl.create :leonardo

    Kor::Export::Excel.new("#{Rails.root}/tmp/export_spec", :kind_id => leonardo.kind_id).run

    book = Spreadsheet.open("#{Rails.root}/tmp/export_spec/entities.0001.xls")
    sheet = book.worksheet 0

    expect(sheet.rows.count).to eq(2)
  end

  it "should export only utc" do
    created_at = Time.now
    mona_lisa = FactoryGirl.create :mona_lisa

    Kor::Export::Excel.new("#{Rails.root}/tmp/export_spec").run

    book = Spreadsheet.open("#{Rails.root}/tmp/export_spec/entities.0001.xls")
    sheet = book.worksheet 0

    expect(sheet.rows[1][10]).to be_utc
    expect(sheet.rows[1][10].to_f).to be_within(1.5).of(created_at.to_f)
  end

end