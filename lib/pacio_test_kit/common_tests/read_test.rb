require_relative '../interactions_test'
require_relative '../test_helpers'

module PacioTestKit
  class ReadTest < Inferno::Test
    include PacioTestKit::InteractionsTest
    include PacioTestKit::TestHelpers

    title 'Server returns correct resource from read interaction'
    id :pacio_resource_read
    description 'A server SHALL support the read interaction.'

    input :resource_ids,
          title: 'ID(s) for a given profile resources present on the server',
          description: 'If providing multiple IDs, separate them by a comma and a space. e.g. id_1, id_2, id_3',
          optional: true

    def resource_type
      config.options[:resource_type]
    end

    def tag
      config.options[:profile]
    end

    def resource_ids_from_create_request
      successful_request = load_tagged_requests("#{tag}_Create").find { |request| request.status == 201 }
      skip_if successful_request.nil?, "All #{tag} create requests were unsuccessful."

      location_header = successful_request.headers.find { |header| header.name.downcase == 'location' }
      skip_if location_header.nil?, "No location header was presented in #{tag} create response."

      # Extract resource ID using regex for better performance
      match = location_header.value.match(%r{/#{resource_type}/([A-Za-z0-9\-\.]{1,64})})

      return nil unless match

      extracted_id = match[1]
      extracted_id.blank? ? nil : extracted_id
    end

    run do
      resource_ids_to_use = resource_ids.blank? ? resource_ids_from_create_request : resource_ids
      skip_if resource_ids_to_use.blank?, 'No resource id provided for the read interaction'

      id_list = resource_ids_to_use.split(',').map(&:strip).reject(&:blank?)
      read_and_validate_resources(id_list, tag)

      no_error_validation("Failed to read #{resource_type} resource(s). See error messages for details.")
    end
  end
end
