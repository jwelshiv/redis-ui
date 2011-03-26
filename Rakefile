require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "redis-ui"
  gem.homepage = "http://github.com/jwelshiv/redis-ui"
  gem.license = "MIT"
  gem.summary = %Q{Sinatra backed redis ui}
  gem.description = %Q{RedisUI is a redis db web accessible viewer}
  gem.email = "james@supermatter.com"
  gem.authors = ["jwelshiv"]

  gem.add_development_dependency "bacon", ">= 0"
  gem.add_runtime_dependency 'redis', ">= 0"
  gem.add_runtime_dependency 'sinatra', ">= 1"
  gem.add_runtime_dependency 'json', ">= 0"
  
  gem.files.include 'lib/*.rb' 
  gem.files.include 'lib/views/*.erb' 
  gem.files.include 'lib/static/stylesheets/*.css' 
  gem.files.include 'lib/static/javascript/*.js' 
  
  gem.executables = ['redis-ui']  
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "Anyhub #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

Jeweler::GemcutterTasks.new
