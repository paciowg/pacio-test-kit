require_relative '../pacio_profiles'
require_relative '../interactions_test'

module PacioTestKit
  class UpdateTest < Inferno::Test
    include PacioTestKit::PacioProfiles
    include PacioTestKit::InteractionsTest

    title 'Resources returned in previous read tests can be updated'
    id :pacio_resource_update
    description %(
      This test verifies resources returned from the read tests are able to be updated.

      This test will be skipped if no resource read requests were made in
      previous tests or if all requests were unsuccessful.
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

      only_read_requests = requests.select { |request| request.verb.downcase == 'read' }
      skip_if only_read_requests.empty?, "There are no #{tag} resource read requests."

      successful_requests = requests.select { |request| request.status == 200 }
      skip_if successful_requests.empty?, "All #{tag} resource read requests were unsuccessful."

      resources_to_validate = successful_requests.map(&:resource).uniq.compact
      resources_to_validate.each do |resource|
        # check if metadata has changed
      end

      # call create method if unable to update from id obtained from read response

      error_msg = "One or more of the #{tag} resources returned in previous read tests are " \
                  'unable to be updated.'
      no_error_validation(error_msg)
    end
  end
end
