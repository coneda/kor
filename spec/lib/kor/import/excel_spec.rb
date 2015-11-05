require "rails_helper"

describe Kor::Import::Excel do

  before :each do
    admin = FactoryGirl.create :admin

    FactoryGirl.create :mona_lisa, :updater => admin
    FactoryGirl.create :der_schrei, :updater => admin
    FactoryGirl.create :leonardo, :updater => admin, :datings => [
      FactoryGirl.build(:leonardo_lifespan)
    ]

    Kor::Export::Excel.new("#{Rails.root}/tmp/export_spec").run
  end

  it "should not re-create deleted entities" do
    Entity.last.destroy
    Kor::Import::Excel.new("#{Rails.root}/tmp/export_spec", :verbose => false).run
    expect(Entity.count).to eq(2)
  end

  it "should import 3 entities, one of them new" do
    Entity.last.destroy
    book = Spreadsheet.open("#{Rails.root}/tmp/export_spec/entities.0001.xls")
    sheet = book.worksheet 0
    sheet[3, 0] = nil
    sheet[3, 1] = nil
    system "rm #{Rails.root}/tmp/export_spec/entities.0001.xls"
    book.write "#{Rails.root}/tmp/export_spec/entities.0001.xls"
    Kor::Import::Excel.new("#{Rails.root}/tmp/export_spec", :verbose => false).run
    expect(Entity.count).to eq(3)
    expect(Entity.last.name).to eq("Leonardo da Vinci")
  end

  it "should refuse to update with non passing validations" do
    book = Spreadsheet.open("#{Rails.root}/tmp/export_spec/entities.0001.xls")
    sheet = book.worksheet 0
    sheet[3, 3] = nil
    system "rm #{Rails.root}/tmp/export_spec/entities.0001.xls"
    book.write "#{Rails.root}/tmp/export_spec/entities.0001.xls"
    Kor::Import::Excel.new("#{Rails.root}/tmp/export_spec", :verbose => false).run
    expect(Entity.count).to eq(3)
    expect(Entity.last.name).to eq("Leonardo da Vinci")
  end

  it "should override validations if told to do so" do
    book = Spreadsheet.open("#{Rails.root}/tmp/export_spec/entities.0001.xls")
    sheet = book.worksheet 0
    sheet[3, 3] = nil
    system "rm #{Rails.root}/tmp/export_spec/entities.0001.xls"
    book.write "#{Rails.root}/tmp/export_spec/entities.0001.xls"
    Kor::Import::Excel.new("#{Rails.root}/tmp/export_spec",
      :verbose => false,
      :ignore_validations => true
    ).run
    expect(Entity.count).to eq(3)
    expect(Entity.last.name).to eq(nil)
  end

  it "should refuse to update with insufficient permissions" do
    FactoryGirl.create :guest
    Entity.last.destroy
    book = Spreadsheet.open("#{Rails.root}/tmp/export_spec/entities.0001.xls")
    sheet = book.worksheet 0
    sheet[3, 0] = nil
    sheet[3, 1] = nil
    system "rm #{Rails.root}/tmp/export_spec/entities.0001.xls"
    book.write "#{Rails.root}/tmp/export_spec/entities.0001.xls"
    Kor::Import::Excel.new("#{Rails.root}/tmp/export_spec",
      :verbose => false,
      :username => "guest",
      :obey_permissions => true
    ).run
    expect(Entity.count).to eq(2)
  end

  it "should override permissions if told to do so" do
    FactoryGirl.create :guest
    Entity.last.destroy
    book = Spreadsheet.open("#{Rails.root}/tmp/export_spec/entities.0001.xls")
    sheet = book.worksheet 0
    sheet[3, 0] = nil
    sheet[3, 1] = nil
    system "rm #{Rails.root}/tmp/export_spec/entities.0001.xls"
    book.write "#{Rails.root}/tmp/export_spec/entities.0001.xls"
    Kor::Import::Excel.new("#{Rails.root}/tmp/export_spec",
      :verbose => false,
      :username => "guest",
    ).run
    expect(Entity.count).to eq(3)
    expect(Entity.last.updater.name).to eq("guest")
  end

  it "should import new datings" do
    Entity.destroy_all

    book = Spreadsheet.open("#{Rails.root}/tmp/export_spec/entities.0001.xls")
    sheet = book.worksheet 0
    sheet[3, 0] = nil
    sheet[3, 1] = nil
    sheet[3, 15] = JSON.dump([{"label" => "Dating", "dating_string" => "1655"}])
    system "rm #{Rails.root}/tmp/export_spec/entities.0001.xls"
    book.write "#{Rails.root}/tmp/export_spec/entities.0001.xls"

    Kor::Import::Excel.new("#{Rails.root}/tmp/export_spec", :verbose => false).run

    expect(Entity.count).to eq(1)
    expect(Entity.first.datings.count).to eq(1)
    expect(Entity.first.datings.first.dating_string).to eq("1655")
  end

  it "should update existing datings" do
    Entity.last.datings.first.update_attributes(:dating_string => "1655")

    Kor::Import::Excel.new("#{Rails.root}/tmp/export_spec", :verbose => false).run
    expect(Entity.count).to eq(3)

    expect(Entity.last.datings.count).to eq(1)
    expect(Entity.last.datings.first.dating_string).to eq("1452 bis 1519")
  end

  it "should delete datings" do
    book = Spreadsheet.open("#{Rails.root}/tmp/export_spec/entities.0001.xls")
    sheet = book.worksheet 0
    sheet[3, 15] = JSON.dump([])
    system "rm #{Rails.root}/tmp/export_spec/entities.0001.xls"
    book.write "#{Rails.root}/tmp/export_spec/entities.0001.xls"

    Kor::Import::Excel.new("#{Rails.root}/tmp/export_spec", :verbose => false).run

    expect(Entity.count).to eq(3)
    expect(Entity.last.datings.count).to eq(0)
  end

  it "should not import timestamps" do
    created_at = Entity.where(:name => "Leonardo da Vinci").first.created_at

    book = Spreadsheet.open("#{Rails.root}/tmp/export_spec/entities.0001.xls")
    
    sheet = book.worksheet 0
    new_created_at = Entity.where(:name => "Leonardo da Vinci").first.created_at

    expect(new_created_at).to eq(created_at)
  end

  it "should delete entities" do
    book = Spreadsheet.open("#{Rails.root}/tmp/export_spec/entities.0001.xls")
    sheet = book.worksheet 0
    sheet[3, 2] = "something"
    system "rm #{Rails.root}/tmp/export_spec/entities.0001.xls"
    book.write "#{Rails.root}/tmp/export_spec/entities.0001.xls"

    Kor::Import::Excel.new("#{Rails.root}/tmp/export_spec", :verbose => false).run

    leonardo = Entity.where(:name => "Leonardo da Vinci").first
    expect(leonardo).to be_nil
  end

end