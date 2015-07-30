# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'capistrano/bigbro/version'

Gem::Specification.new do |spec|
  spec.name          = 'capistrano-bigbro'
  spec.version       = Capistrano::Bigbro::VERSION
  spec.authors       = ['aligo Kang']
  spec.email         = ['aligo_x@163.com']

  spec.summary       = %q{}
  spec.description   = %q{}
  spec.homepage      = 'https://github.com/aligo/capistrano-bigbro'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split('\x0').reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ['lib']


  spec.required_ruby_version     = '>= 1.9.3'

  spec.add_dependency 'capistrano', '>= 3.0'

  spec.add_development_dependency 'bundler', '~> 1.9'
  spec.add_development_dependency 'rake', '~> 10.0'
end
