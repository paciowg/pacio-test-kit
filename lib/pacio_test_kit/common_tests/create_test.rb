require_relative '../interactions_test'

module PacioTestKit
  class CreateTest < Inferno::Test
    include PacioTestKit::InteractionsTest

    title 'Server makes correct resource from create interaction'
    id :pacio_resource_create
    description 'A server SHALL support the create interaction.'

    input :resource_inputs,
          title: 'Resource to create on the server',
          description: 'Provide a json resource to create on the server.'

    def resource_type
      config.options[:resource_type]
    end

    def tag
      config.options[:profile]
    end

    run do
      create_and_validate_resources(resource_inputs, tag)
      no_error_validation("Failed to create #{resource_type} resource(s). See error messages for details.")
    end
  end
end
