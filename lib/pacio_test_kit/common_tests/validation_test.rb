require_relative '../pacio_profiles'
require_relative 'interactions_test'
require_relative '../test_helpers'

module PacioTestKit
  class ValidationTest < Inferno::Test
    include PacioTestKit::PacioProfiles
    include PacioTestKit::InteractionsTest
    include PacioTestKit::TestHelpers

    title 'Resources returned in previous tests conform to the given profile'
    id :pacio_resource_validation

    def resource_type
      config.options[:resource_type]
    end

    def tag
      config.options[:profile]
    end

    def ig_version
      config.options[:ig_version]
    end

    def profile_url
      return nil unless PACIO_PROFILES[tag]

      tag&.include?('USCore') ? PACIO_PROFILES[tag] : "#{PACIO_PROFILES[tag]}|#{ig_version}"
    end

    run do
      read_requests = load_tagged_requests(tag)
      search_requests = load_tagged_requests("#{tag}_Search")
      all_requests = read_requests + search_requests
      skip_if all_requests.blank?, "No #{tag} resource read/search request was made in previous tests as expected."

      successful_requests = all_requests.select { |request| request.status == 200 }
      skip_if successful_requests.empty?, "All #{tag} resource read/search requests were unsuccessful."

      base_resources = successful_requests.map(&:resource).compact
      resources_to_validate = extract_target_resources(base_resources, resource_type)

      skip_if resources_to_validate.blank?,
              " Unable to perform validation: No #{tag} resource was returned in previous tests as expected."

      resources_to_validate.each do |resource|
        resource_is_valid?(resource:, profile_url:)
      end

      conformance_target = if profile_url.nil?
                             "FHIR base #{resource_type} resource type"
                           else
                             "profile #{profile_url}"
                           end

      error_msg = "One or more of the #{tag} resources returned in previous tests do not " \
                  "conform to the #{conformance_target}"

      no_error_validation(error_msg)
    end
  end
end
