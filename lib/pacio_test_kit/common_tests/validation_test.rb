require_relative '../pacio_profiles'
require_relative '../interactions_test'

module PacioTestKit
  class ValidationTest < Inferno::Test
    include PacioTestKit::PacioProfiles
    include PacioTestKit::InteractionsTest

    title 'Resources returned in previous tests conform to the given profile'
    id :pacio_resource_validation

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
      skip_if successful_requests.empty?, "All #{tag} resource read requests were unsuccessful."

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
