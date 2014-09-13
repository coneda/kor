Before do
  begin
    Sunspot.remove_all!
  rescue => e
  end

  DatabaseCleaner.clean
  eval File.read("#{Rails.root}/db/seeds.rb")
end
