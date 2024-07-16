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

    input :id_to_update,
          title: 'The id of the FHIR resource to update on the server',
          description: 'Provide a string id of a resource to update on the server.'

    input :new_resource,
          title: 'The resource to update the FHIR resource on the server',
          description: 'Provide a FHIR resource to update on the server.'

    def resource_type
      config.options[:resource_type]
    end

    def tag
      config.options[:profile]
    end

    run do
      load_tagged_requests(tag)
      skip_if requests.blank?, "No #{tag} resource read request was made in previous tests as expected."

      successful_requests = requests.select { |request| request.verb.downcase == 'read' && request.status == 200 }
      skip_if successful_requests.empty?, "All #{tag} resource read requests were unsuccessful."

      resources_to_update = successful_requests.map(&:resource).uniq.compact
      resource_to_update = resources_to_update.select { |resource| resource.id.to_s == id_to_update.to_s }

      assert_valid_json(new_resource) unless resource_to_update.present?
      update_and_validate_resource(id_to_update.to_s, JSON.parse(new_resource))

      error_msg = "One or more of the #{tag} resources returned in previous read tests are " \
                  'unable to be updated.'
      no_error_validation(error_msg)
    end
  end
end
