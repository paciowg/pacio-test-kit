Gem::Specification.new do |spec|
  spec.name          = 'pacio_test_kit'
  spec.version       = '0.0.1'
  spec.authors       = ['Vanessa Fotso']
  # spec.email         = ['TODO']
  spec.summary       = 'PACIO Use Cases Test Kit'
  spec.description   = 'PACIO Use Cases Test Kit'
  # spec.homepage      = 'TODO'
  spec.license       = 'Apache-2.0'
  spec.add_runtime_dependency 'inferno_core', '~> 0.5.0'
  spec.add_runtime_dependency 'smart_app_launch_test_kit', '~> 0.4.1'
  spec.add_runtime_dependency 'tls_test_kit', '~> 0.2.1'
  spec.required_ruby_version = Gem::Requirement.new('>= 3.1.2')
  # spec.metadata['homepage_uri'] = spec.homepage
  # spec.metadata['source_code_uri'] = 'TODO'
  spec.files = [
    Dir['lib/**/*.rb'],
    Dir['lib/**/*.json'],
    'LICENSE'
  ].flatten

  spec.require_paths = ['lib']
end
