# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'subiam/version'

Gem::Specification.new do |spec|
  spec.name          = 'subiam'
  spec.version       = Subiam::VERSION
  spec.authors       = ['Genki Sugawara', 'Yuya YAGUCHI']
  spec.email         = ['yuya.yaguchi@gree.net']
  spec.summary       = %q{Subiam is a tool to manage IAM. Forked from Miam.}
  spec.description   = %q{Subiam is a tool to manage IAM. It defines the state of IAM using DSL, and updates IAM according to DSL. Forked from Miam.}
  spec.homepage      = 'https://github.com/yayugu/subiam'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'aws-sdk-core', '~> 2.3'
  spec.add_dependency 'ruby-progressbar'
  spec.add_dependency 'parallel'
  spec.add_dependency 'term-ansicolor'
  spec.add_dependency 'diffy'
  spec.add_dependency 'hashie'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 3.4'
  spec.add_development_dependency 'rspec-instafail'
  spec.add_development_dependency 'coveralls'
end
