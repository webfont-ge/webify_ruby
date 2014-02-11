$:.push File.expand_path("../lib", __FILE__)

require "webify_ruby/version"

Gem::Specification.new do |s|
  s.name        = "webify_ruby"
  s.version     = WebifyRuby::VERSION
  s.authors     = ['Dachi Natsvlishvili']
  s.email       = ['dnatsvlishvili@gmail.com']
  s.homepage    = 'https://github.com/dachi-gh/webify_ruby'
  s.summary     = 'A Ruby wrapper for Webify application written in Haskell'
  s.description = 'WebifyRuby communicates with Webify and provides nice and easy working interface'
  s.licenses    = ['MIT']

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc", "Gemfile", "webify_ruby.gemspec"]
  s.test_files = Dir["test/**/*"]

  s.add_development_dependency 'bundler', '~> 1.4'
  s.add_development_dependency 'rails', '~> 4.0'
  s.add_development_dependency 'sqlite3', '~> 1.3'
  s.add_development_dependency 'coveralls', '~> 0.7'
  s.add_development_dependency 'simplecov', '~> 0.7'
  s.add_development_dependency 'rake', '~> 0.8'
end
