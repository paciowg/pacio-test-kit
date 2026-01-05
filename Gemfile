# frozen_string_literal: true

source "https://rubygems.org"

gemspec

group :development, :test do
  gem 'debug'

  gem "rubocop", "~> 1.56"
  gem 'rubocop-rspec', require: false
  gem "rubocop-rake", "~> 0.6.0"

  gem 'pacio_pfe_test_kit', git: 'https://github.com/paciowg/pacio-pfe-test-kit.git', branch: 'generator'
  gem 'pacio_smp_test_kit', git: 'https://github.com/paciowg/pacio-smp-test-kit.git', branch: 'generator'
  gem 'pacio_toc_test_kit', git: 'https://github.com/paciowg/pacio-toc-test-kit.git', branch: 'generate'
end

group :test do
  gem 'database_cleaner-sequel', '~> 1.8'
  gem 'factory_bot', '~> 6.1'
  gem 'rack-test'
  gem 'rspec', '~> 3.10'
  gem 'webmock', '~> 3.11'
end
