lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'mudfly/version'

Gem::Specification.new do |spec|
  
  spec.name          = 'mudfly'
  spec.version       = Mudfly::VERSION
  spec.author        = 'Pablo Elices'
  spec.email         = 'contact@pabloelic.es'
  spec.description   = 'Mudfly is a Ruby wrapper for the PageSpeed Insights API.'
  spec.summary       = 'A Ruby wrapper for the PageSpeed Insights API.'
  spec.homepage      = 'https://github.com/pabloelices/mudfly'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.0.0'

  spec.add_runtime_dependency 'faraday'
  spec.add_runtime_dependency 'thor'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'

end