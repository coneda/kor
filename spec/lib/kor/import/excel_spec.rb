require "rails_helper"

RSpec.describe Kor::Import::Excel do
  before :each do
    Kor::Export::Excel.new("#{Rails.root}/tmp/export_spec").run
  end

  it "should not re-create deleted entities" do
    Entity.last.destroy
    Kor::Import::Excel.new("#{Rails.root}/tmp/export_spec", verbose: false).run
    expect(Entity.count).to eq(6)
  end

  it "should import 7 entities, one of them new" do
    mona_lisa = Entity.find_by! name: 'Mona Lisa'
    mona_lisa.destroy

    book = Spreadsheet.open("#{Rails.root}/tmp/export_spec/entities.0001.xls")
    sheet = book.worksheet 0
    sheet[2, 0] = nil
    sheet[2, 1] = nil
    system "rm #{Rails.root}/tmp/export_spec/entities.0001.xls"
    book.write "#{Rails.root}/tmp/export_spec/entities.0001.xls"

    Kor::Import::Excel.new("#{Rails.root}/tmp/export_spec", verbose: false).run

    expect(Entity.count).to eq(7)
    expect(Entity.last.name).to eq("Mona Lisa")
  end

  it "should refuse to update with non passing validations" do
    book = Spreadsheet.open("#{Rails.root}/tmp/export_spec/entities.0001.xls")
    sheet = book.worksheet 0
    sheet[3, 3] = nil
    system "rm #{Rails.root}/tmp/export_spec/entities.0001.xls"
    book.write "#{Rails.root}/tmp/export_spec/entities.0001.xls"

    Kor::Import::Excel.new("#{Rails.root}/tmp/export_spec", verbose: false).run

    expect(Entity.count).to eq(7)
  end

  it "should override validations if told to do so" do
    mona_lisa = Entity.find_by! name: 'Mona Lisa'

    book = Spreadsheet.open("#{Rails.root}/tmp/export_spec/entities.0001.xls")
    sheet = book.worksheet 0
    sheet[2, 3] = nil
    system "rm #{Rails.root}/tmp/export_spec/entities.0001.xls"
    book.write "#{Rails.root}/tmp/export_spec/entities.0001.xls"

    Kor::Import::Excel.new("#{Rails.root}/tmp/export_spec",
      verbose: false,
      ignore_validations: true
    ).run

    expect(Entity.count).to eq(7)
    expect(mona_lisa.reload.name).to eq(nil)
  end

  it "should refuse to update with insufficient permissions" do
    mona_lisa = Entity.find_by! name: 'Mona Lisa'
    mona_lisa.destroy

    book = Spreadsheet.open("#{Rails.root}/tmp/export_spec/entities.0001.xls")
    sheet = book.worksheet 0
    sheet[2, 0] = nil
    sheet[2, 1] = nil
    system "rm #{Rails.root}/tmp/export_spec/entities.0001.xls"
    book.write "#{Rails.root}/tmp/export_spec/entities.0001.xls"

    Kor::Import::Excel.new("#{Rails.root}/tmp/export_spec",
      verbose: false,
      username: "guest",
      obey_permissions: true
    ).run

    expect(Entity.count).to eq(6)
  end

  it "should override permissions if told to do so" do
    mona_lisa = Entity.find_by! name: 'Mona Lisa'
    mona_lisa.destroy

    book = Spreadsheet.open("#{Rails.root}/tmp/export_spec/entities.0001.xls")
    sheet = book.worksheet 0
    sheet[2, 0] = nil
    sheet[2, 1] = nil
    system "rm #{Rails.root}/tmp/export_spec/entities.0001.xls"
    book.write "#{Rails.root}/tmp/export_spec/entities.0001.xls"

    Kor::Import::Excel.new("#{Rails.root}/tmp/export_spec",
      verbose: false,
      username: "guest",
    ).run

    expect(Entity.count).to eq(7)
    expect(Entity.last.updater.name).to eq("guest")
  end

  # TODO: continue here!

  it "should import new datings" do
    book = Spreadsheet.open("#{Rails.root}/tmp/export_spec/entities.0001.xls")
    sheet = book.worksheet 0
    sheet[2, 15] = [{'label' => 'entstanden um', 'dating_string' => '1677'}].to_json
    system "rm #{Rails.root}/tmp/export_spec/entities.0001.xls"
    book.write "#{Rails.root}/tmp/export_spec/entities.0001.xls"

    Kor::Import::Excel.new("#{Rails.root}/tmp/export_spec", verbose: false).run

    mona_lisa = Entity.find_by! name: 'Mona Lisa'
    expect(mona_lisa.datings.first.dating_string).to eq('1677')
  end

  it "should update existing datings" do
    leonardo = Entity.find_by! name: 'Leonardo'
    leonardo.datings.last.update dating_string: '1788'

    Kor::Import::Excel.new("#{Rails.root}/tmp/export_spec", verbose: false, ignore_stale: true).run
    expect(Entity.count).to eq(7)

    expect(leonardo.reload.datings.count).to eq(1)
    expect(leonardo.datings.last.dating_string).to eq("1452 bis 1519")
  end

  it "should delete datings" do
    book = Spreadsheet.open("#{Rails.root}/tmp/export_spec/entities.0001.xls")
    sheet = book.worksheet 0
    sheet[1, 15] = JSON.dump([])
    system "rm #{Rails.root}/tmp/export_spec/entities.0001.xls"
    book.write "#{Rails.root}/tmp/export_spec/entities.0001.xls"

    Kor::Import::Excel.new("#{Rails.root}/tmp/export_spec", verbose: false).run

    leonardo = Entity.find_by! name: 'Leonardo'
    expect(Entity.count).to eq(7)
    expect(leonardo.datings.count).to eq(0)
  end

  it "should not import timestamps" do
    skip "this doesn't test what it says it does"

    # created_at = leonardo.created_at
    # book = Spreadsheet.open("#{Rails.root}/tmp/export_spec/entities.0001.xls")
    # expect(leonardo.reload.created_at).to eq(created_at)
  end

  it "should delete entities" do
    book = Spreadsheet.open("#{Rails.root}/tmp/export_spec/entities.0001.xls")
    sheet = book.worksheet 0
    sheet[2, 2] = "something"
    system "rm #{Rails.root}/tmp/export_spec/entities.0001.xls"
    book.write "#{Rails.root}/tmp/export_spec/entities.0001.xls"

    Kor::Import::Excel.new("#{Rails.root}/tmp/export_spec", verbose: false).run

    expect(Entity.find_by name: 'Mona Lisa').to be_nil
  end
end
