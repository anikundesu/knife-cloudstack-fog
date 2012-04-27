# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "knife-cloudstack/version"

Gem::Specification.new do |s|
  s.name        = "knife-cloudstack-fog"
  s.version     = Knife::Cloudstack::VERSION
  s.platform    = Gem::Platform::RUBY
  s.has_rdoc = true
  s.extra_rdoc_files = ["README.rdoc", "LICENSE" ]
  s.authors     = ["Chirag Jog", "Jeff Moody"]
  s.email       = ["chirag@clogeny.com", "jmoody@datapipe.com"]
  s.homepage    = "https://github.com/fifthecho/knife-cloudstack-fog"
  s.summary     = %q{Cloudstack Compute Support for Chef's Knife Command}
  s.description = %q{Support for the Chef Knife command, leveraging FOG, for the Citrix CloudStack API}
  s.files = Dir['lib/**/*.rb']
  s.require_paths = ["lib"]

  s.add_dependency "fog", "~> 1.3.1"
end
