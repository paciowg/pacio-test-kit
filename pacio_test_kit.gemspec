require_relative 'lib/pacio_test_kit/version'

Gem::Specification.new do |spec|
  spec.name          = 'pacio_test_kit'
  spec.version       = PacioTestKit::VERSION
  spec.authors       = ['Vanessa Fotso', 'Kaelyn Jefferson', 'Brian Meshell']
  # spec.email         = ['TODO']
  spec.summary       = 'PACIO Use Cases Test Kit'
  spec.description   = 'PACIO Use Cases Test Kit'
  spec.homepage      = 'https://github.com/paciowg/pacio-test-kit'
  spec.license       = 'Apache-2.0'
  spec.add_runtime_dependency 'inferno_core', '~> 1.0', '>= 1.0.2'
  spec.add_runtime_dependency 'smart_app_launch_test_kit', '~> 1.0'
  spec.add_runtime_dependency 'tls_test_kit', '~> 1.0'
  spec.required_ruby_version = Gem::Requirement.new('>= 3.3.6')
  spec.metadata['inferno_test_kit'] = 'true'
  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.files = `[ -d .git ] && git ls-files -z lib config/presets LICENSE`.split("\x0")

  spec.require_paths = ['lib']
end
