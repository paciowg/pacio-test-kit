require_relative '../interactions_test'

module PacioTestKit
  class CreateTest < Inferno::Test
    include PacioTestKit::InteractionsTest

    title 'Server makes correct resource from create interaction'
    id :pacio_resource_create
    description 'A server SHALL support the create interaction.'

    def resource_type
      config.options[:resource_type]
    end

    def tag
      config.options[:profile]
    end

    def default_example_resource
      config.options[:example_resource]
    end

    run do
      create_and_validate_resources(default_example_resource, tag)

      no_error_validation("Fail to read #{resource_type} resource(s). See error messages for details.")
    end
  end
end
