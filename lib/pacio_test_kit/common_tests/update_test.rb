require_relative '../pacio_profiles'
require_relative '../interactions_test'

module PacioTestKit
  class UpdateTest < Inferno::Test
    include PacioTestKit::PacioProfiles
    include PacioTestKit::InteractionsTest

    title 'Resources returned in previous read tests can be updated'
    id :pacio_resource_update
    description %(
      This test verifies the resource returned from a previous read test is able to be updated.

      This test will be skipped if no resource read request was made in
      previous tests or if the request was unsuccessful.
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

      successful_request = requests.select { |request| request.status == 200 }
      skip_if successful_request.empty?, "The #{tag} resource update request was skipped because" \
                                         'no previous read test was successful.'

      update_and_validate_resource(successful_request[0])

      error_msg = "The #{tag} resource returned in a previous read test was " \
                  'unable to be updated. See error messages for details.'
      no_error_validation(error_msg)
    end
  end
end
