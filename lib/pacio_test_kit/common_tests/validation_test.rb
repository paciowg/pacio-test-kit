require_relative '../pacio_profiles'
require_relative '../interactions_test'

module PacioTestKit
  class ValidationTest < Inferno::Test
    include PacioTestKit::PacioProfiles
    include PacioTestKit::InteractionsTest

    title 'Resources returned in previous tests conform to the given profile'
    id :pacio_resource_validation
    description %(
      This test verifies resources returned from the read and search tests conform to
      the [Pacio #{short_title}](#{PACIO_PROFILES[config.options[:profile]]}).

      It verifies the presence of mandatory elements and that elements with required
      bindings contain appropriate values.

      This test will be skipped if no resource read or search requests were made in
      previous tests or if all requests were unsuccessful.
    )

    def resource_type
      config.options[:resource_type]
    end

    def tag
      config.options[:profile]
    end

    def profile_url
      PACIO_PROFILES[tag]
    end

    run do
      load_tagged_requests(tag)
      skip_if requests.blank?, "No #{tag} resource read or search request was made in previous tests as expected."
      successful_requests = requests.select { |request| request.status == 200 }
      skip_if successful_requests.empty?, "All #{tag} resource read or search requests were unsuccessful."

      resources_to_validate = successful_requests.map(&:resource).uniq.compact
      resources_to_validate.each do |resource|
        resource_is_valid?(resource:, profile_url:)
      end

      error_msg = "One or more of the #{tag} resources returned in previous tests do not " \
                  "conform to the profile #{profile_url}"
      no_error_validation(error_msg)
    end
  end
end
