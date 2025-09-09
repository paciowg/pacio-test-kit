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

    def merged_resource_ids
      return resource_ids unless resource_ids.blank?

      use_id_from_bundle = config.options[:use_id_from_bundle]
      if use_id_from_bundle.present?
        resource_ids_from_bundle_resource(use_id_from_bundle)
      else
        resource_ids_from_create_request
      end
    end

    def resource_ids_from_bundle_resource(bundle_tag)
      successful_requests = load_tagged_requests(bundle_tag).select { |request| request.status == 200 }
      skip_if successful_requests.empty?, "All #{bundle_tag} resource read requests were unsuccessful."

      base_resources = successful_requests.map(&:resource).compact
      resources_to_read = extract_target_resources(base_resources, resource_type)

      skip_if resources_to_read.blank?,
              "Unable to perform read test: No #{tag} resource was returned in previous Bundle tests as expected."

      resources_to_read.map(&:id).join(', ')
    end

    def resource_ids_from_create_request
      successful_request = load_tagged_requests("#{tag}_Create").find { |request| request.status == 201 }
      skip_if successful_request.nil?, "All #{tag} create requests were unsuccessful."

      location_header = successful_request.headers.find { |header| header.name.downcase == 'location' }
      skip_if location_header.nil?, "No location header was presented in #{tag} create response."

      # Extract resource ID using regex for better performance
      match = location_header.value.match(%r{/#{resource_type}/([A-Za-z0-9\-\.]{1,64})})
      match ? match[1] : ''
    end

    run do
      skip_if merged_resource_ids.blank?, 'No resource id provided for the read interaction'

      id_list = merged_resource_ids.split(',').map(&:strip)
      read_and_validate_resources(id_list, tag)

      no_error_validation("Fail to read #{resource_type} resource(s). See error messages for details.")
    end
  end
end
