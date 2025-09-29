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
      successful_request = find_successful_create_request
      location_header = find_location_header(successful_request)
      extract_resource_id(location_header)
    end

    def find_successful_create_request
      successful_request = load_tagged_requests("#{tag}_Create").find { |request| request.status == 201 }
      skip_if successful_request.nil?, "All #{tag} create requests were unsuccessful."
      successful_request
    end

    def find_location_header(request)
      location_header = request.headers.find { |header| header.name.downcase == 'location' }
      skip_if location_header.nil?, "No location header was presented in #{tag} create response."
      location_header
    end

    def extract_resource_id(location_header)
      match = location_header.value.match(%r{/#{resource_type}/([A-Za-z0-9\-\.]{1,64})})
      match.present? ? match[1] : nil
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
