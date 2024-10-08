require_relative '../interactions_test'

module PacioTestKit
  class UpdateTest < Inferno::Test
    include PacioTestKit::InteractionsTest

    title 'Server can update an existing resource.'
    id :pacio_resource_update
    description %(
      This test verifies that a resource obtained from a prior read operation can be successfully updated.

      This test will be skipped if no read requests were made in
      previous tests, or if all requests were unsuccessful.
    )

    def resource_type
      config.options[:resource_type]
    end

    def tag
      config.options[:profile]
    end

    run do
      load_tagged_requests(tag)
      skip_if requests.blank?, "No #{tag} resource read request was made in previous tests as expected."

      successful_requests = requests.select { |request| request.status == 200 }
      skip_if successful_requests.empty?, "All previous #{tag} resource read requests were unsuccessful."

      update_and_validate_resource(successful_requests.first.resource)

      error_msg = "Unable to update #{tag} resource. See error messages for details."
      no_error_validation(error_msg)
    end
  end
end
