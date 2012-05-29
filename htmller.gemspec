$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "htmller/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "htmller"
  s.version     = Htmller::VERSION
  s.authors     = ["Serhiy Tykhanskyy"]
  s.email       = ["serhiy@kvvitka.com"]
  s.homepage    = ""
  s.summary     = ""
  s.description = ""

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "nokogiri"

  s.add_development_dependency "sqlite3"
end
