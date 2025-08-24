# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'deprecate/version'

Gem::Specification.new do |spec|
  spec.name          = 'deprecate'
  spec.version       = Deprecate::VERSION
  spec.authors       = ['Dale Stevens']
  spec.email         = ['dale@twilightcoder.net']
  spec.summary       = 'Easily maintain your codebase by exposing an easy and concise way to mark methods as deprecated.'
  spec.homepage      = 'https://github.com/twilightcoders/deprecate'
  spec.license       = 'MIT'

  spec.required_ruby_version = '>= 2.7.0'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 1.0'
  spec.add_development_dependency 'reek', '~> 6.0'
end
