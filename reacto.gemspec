# coding: utf-8

current_dir = File.dirname(File.realpath(__FILE__))
$LOAD_PATH.unshift(File.join(current_dir, 'lib'))

require 'reacto/version'

Gem::Specification.new do |spec|
  spec.name          = 'reacto'
  spec.version       = Reacto::VERSION
  spec.authors       = ['Nickolay Tzvetinov - Meddle']
  spec.email         = ['n.tzvetinov@gmail.com']
  spec.description   = 'Concurrent Reactive Programming for Ruby'
  spec.summary       = 'Reactive Programming for Ruby with some concurrency thrown into the mix.'
  spec.homepage      = 'https://github.com/meddle0x53/reacto'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rspec', '~> 3.3.0'
  spec.add_development_dependency 'rubocop', '~> 0.49.0'

  spec.add_dependency 'concurrent-ruby', '~> 1.0.2'
end
