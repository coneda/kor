$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
#require "kor_api/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "kor_api"
  #s.version     = KorApi::VERSION
  s.version     = "0.0.1"
  s.authors     = ["Moritz Schepp"]
  s.email       = ["moritz.schepp@gmail.com"]
  s.homepage    = "http://coneda.net"
  s.summary     = "Enables a simple API for kor"
  s.description = "Enables a simple API for kor"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["Rakefile"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.8"
end
