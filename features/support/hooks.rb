Before do
  Sunspot.remove_all!
  DatabaseCleaner.clean
  eval File.read("#{Rails.root}/db/seeds.rb")
end
