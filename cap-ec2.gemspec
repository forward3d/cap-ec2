# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cap-ec2/version'

Gem::Specification.new do |spec|
  spec.name          = "cap-ec2"
  spec.version       = CapEC2::VERSION
  spec.authors       = ["Andy Sykes", "Robert Coleman", "Forward3D Developers"]
  spec.email         = ["github@tinycat.co.uk", "github@robert.net.nz", "developers@forward3d.com"]
  spec.description   = %q{Cap-EC2 is used to generate Capistrano namespaces and tasks from Amazon EC2 instance tags, dynamically building the list of servers to be deployed to.}
  spec.summary       = %q{Cap-EC2 is used to generate Capistrano namespaces and tasks from Amazon EC2 instance tags, dynamically building the list of servers to be deployed to.}
  spec.homepage      = "https://github.com/forward3d/cap-ec2"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  spec.add_dependency 'aws-sdk-ec2'
  spec.add_dependency "capistrano", ">= 3.0"
  spec.add_dependency "terminal-table"
  spec.add_dependency "colorize"
end
