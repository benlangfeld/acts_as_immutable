# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "acts_as_immutable/version"

Gem::Specification.new do |s|
  s.name        = "acts_as_immutable"
  s.version     = ActsAsImmutable::VERSION
  s.authors     = ["Simon Mathieu", "NuLayer Inc."]
  s.email       = ["simon@pagerduty.com"]
  s.homepage    = ""
  s.summary     = %q{Immutable ActiveRecord models}
  s.description = %q{A Rails plugin that will ensure an ActiveRecord object is immutable once
saved. Optionally, you can specify attributes to be mutable if the object
is in a particular state (block evaluates to true).}

  s.rubyforge_project = "acts_as_immutable"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rake"
  s.add_development_dependency "activerecord", '4.2.0'
  s.add_development_dependency "sqlite3"
  s.add_development_dependency "ruby-debug"
  # s.add_runtime_dependency "rest-client"
end
