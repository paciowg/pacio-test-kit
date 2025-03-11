require_relative '../interactions_test'

module PacioTestKit
  class CreateTest < Inferno::Test
    include PacioTestKit::InteractionsTest

    title 'Server accepts create interaction'
    id :pacio_resource_create
    description 'A server SHALL support the create interaction.'

    input :resource_input,
          title: 'FHIR resource to create on the server',
          description: %(Provide a json resource to create on the server. 
            (Please make sure other resources referenced in the input 
            resource are already present on the server.))

    def resource_type
      config.options[:resource_type]
    end

    run do
      assert_valid_json(resource_input)
      create_and_validate_resource(JSON.parse(resource_input))
      no_error_validation("Failed to create #{resource_type} resource. See error messages for details.")
    end
  end
end
