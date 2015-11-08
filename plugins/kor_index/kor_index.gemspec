$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
#require "kor_index/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "kor_index"
#  s.version     = KorIndex::VERSION
  s.version     = "0.0.1"
  s.authors     = ["Moritz Schepp"]
  s.email       = ["moritz.schepp@gmail.com"]
  s.homepage    = "https://coneda.net"
  s.summary     = "Provides SOLR indexing for kor"
  s.description = "Provides SOLR indexing for kor"

  s.files = Dir["{app,config,db,lib}/**/*"] + []
  s.test_files = Dir["test/**/*"]
end
