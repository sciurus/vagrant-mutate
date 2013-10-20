# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vagrant-mutate/version'

Gem::Specification.new do |spec|
  spec.name          = "vagrant-mutate"
  spec.version       = VagrantMutate::VERSION
  spec.authors       = ["Brian Pitts"]
  spec.email         = ["brian@polibyte.com"]
  spec.description   = %q{Convert vagrant boxes to work with different providers}
  spec.summary       = spec.description
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "archive-tar-minitar", "~> 0.5.0"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
