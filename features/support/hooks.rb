Before do
  DatabaseCleaner.clean
  eval File.read("#{Rails.root}/db/seeds.rb")
end
