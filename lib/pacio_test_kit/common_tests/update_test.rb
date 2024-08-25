require_relative '../interactions_test'

module PacioTestKit
  class UpdateTest < Inferno::Test
    include PacioTestKit::PacioProfiles
    include PacioTestKit::InteractionsTest

    title 'A resource returned in previous read tests can be updated'
    id :pacio_resource_update
    description %(
      This test verifies that a resource obtained from a prior read operation can be successfully updated.

      This test will be skipped if no read requests were made in
      previous tests, or if all requests were unsuccessful.
    )

    input :updated_status,
          title: 'Status to update a resource present on the server',
          description: 'Updated status must be in the observation-status value set'

    def resource_type
      config.options[:resource_type]
    end

    def tag
      config.options[:profile]
    end

    run do
      load_tagged_requests(tag)
      skip_if requests.blank?, "No #{tag} resource read request was made in previous tests as expected."

      successful_resource = requests.select { |request| request.status == 200 }
      skip_if successful_resource.empty?, "All previous #{tag} resource read requests were unsuccessful."

      update_and_validate_resource(successful_resource[0], updated_status)
    end
  end
end
