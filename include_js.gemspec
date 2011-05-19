# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'include_js/version'

Gem::Specification.new do |s|
  s.name        = "include_js"
  s.version     = IncludeJS::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Andreas Haller", "Thorben Schröder"]
  s.email       = ["andreashaller@gmail.com"]
  s.homepage    = "https://github.com/ahx/include_js"
  s.summary     = %q{CommonJS Modules in Ruby}
  s.description = %q{Use CommonJS Modules inside Ruby via therubyracer}

  s.rubyforge_project = "include_js"
  
  s.add_dependency 'therubyracer', '~> 0.8.1'
  
  s.add_development_dependency 'rspec', '~> 2.6.0'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ["lib"]
end
