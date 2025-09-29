require_relative '../interactions_test'
require_relative '../test_helpers'

module PacioTestKit
  class CreateTest < Inferno::Test
    include PacioTestKit::InteractionsTest
    include PacioTestKit::TestHelpers

    title 'Server accepts create interaction'
    id :pacio_resource_create
    description 'A server SHALL support the create interaction.'

    input :resource_input,
          title: 'FHIR resource to create on the server',
          # rubocop:disable Layout/LineLength
          description: 'Provide a json resource to create on the server. Please make sure other resources referenced in the input resource are already present on the server.'
    # rubocop:enable Layout/LineLength

    def resource_type
      config.options[:resource_type]
    end

    def tag
      config.options[:profile]
    end

    run do
      assert_valid_json(resource_input)
      create_and_validate_resource(JSON.parse(resource_input), tag)
      no_error_validation("Failed to create #{resource_type} resource. See error messages for details.")
    end
  end
end
