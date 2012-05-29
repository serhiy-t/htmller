$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "htmller/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "htmller"
  s.version     = Htmller::VERSION
  s.authors     = ["TODO: Your name"]
  s.email       = ["TODO: Your email"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of Htmller."
  s.description = "TODO: Description of Htmller."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.3"

  s.add_development_dependency "sqlite3"
end
