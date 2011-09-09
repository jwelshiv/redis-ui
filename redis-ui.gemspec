# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "redis-ui/version"

Gem::Specification.new do |s|
  s.name        = "redis-ui"
  s.version     = Redis::Ui::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["supermatter", "jwelshiv"]
  s.email       = ["james@supermatter.com"]
  s.homepage    = "http://github.com/jwelshiv/redis-ui"
  s.summary     = "Sinatra backed redis ui"
  s.description = "View and manage redis store"

  s.rubyforge_project = "redis-ui"
  
  s.licenses = ["MIT"]
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_development_dependency 'bacon'
  
  s.add_runtime_dependency 'json'
  s.add_runtime_dependency 'hiredis', '~> 0.3.1'
  s.add_runtime_dependency 'redis-namespace', '~> 1.0.2'
  s.add_runtime_dependency 'sinatra'
  s.add_runtime_dependency 'sinatra-respond_to'
  s.add_runtime_dependency 'vegas'
end