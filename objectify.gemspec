# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "objectify/version"

Gem::Specification.new do |s|
  s.name        = "objectify"
  s.version     = Objectify::VERSION
  s.authors     = ["James Golick"]
  s.email       = ["jamesgolick@gmail.com"]
  s.homepage    = "https://github.com/bitlove/objectify"
  s.summary     = %q{Objects on rails.}
  s.description = %q{Objects on rails.}

  s.rubyforge_project = "objectify"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rspec", "~> 2.4.0"
  s.add_development_dependency "bundler", ">= 1.0.0"
  s.add_development_dependency "jeweler", "~> 1.6.4"
  s.add_development_dependency "bourne", "1.0"
  s.add_development_dependency "mocha", "0.9.8"

  s.add_runtime_dependency "rails", ">=3.0.0"
  s.add_runtime_dependency "i18n"
end
