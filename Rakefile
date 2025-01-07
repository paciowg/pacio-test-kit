begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
  task default: :spec
rescue LoadError # rubocop:disable Lint/SuppressedException
end

namespace :db do
  desc 'Apply changes to the database'
  task :migrate do
    require 'inferno/config/application'
    require 'inferno/utils/migration'
    Inferno::Utils::Migration.new.run
  end
end

namespace :pacio_ms do
  desc 'Generate MS tests'
  task :generate do
    require_relative 'lib/pacio_test_kit/generator'

    PacioTestKit::Generator.generate
  end
end
