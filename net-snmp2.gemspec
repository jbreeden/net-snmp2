# -*- encoding: utf-8 -*-
lib = File.expand_path("../lib", __FILE__)
$:.unshift lib
require 'net/snmp/version'

Gem::Specification.new do |s|
  s.name        = "net-snmp2"
  s.version     = Net::SNMP::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Ron McClain", "Jared Breeden"]
  s.email       = ["jared.breeden@gmail.com"]
  s.homepage    = "https://github.com/jbreeden/net-snmp2"
  s.summary     = %q{Object oriented wrapper around C net-snmp libraries}
  s.description = %q{Cross platform net-snmp wrapper for Ruby, building on the original net-snmp gem}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # Documentation options
  s.has_rdoc = true
  s.extra_rdoc_files = %w{ README.md }
  s.rdoc_options = ["--main=README.md", "--markup=markdown", "--line-numbers", "--inline-source", "--title=#{s.name}-#{s.version} Documentation"]

  s.add_dependency 'nice-ffi'
  s.add_dependency 'pry'
  s.add_development_dependency "rspec"
  s.add_development_dependency "eventmachine"
end
