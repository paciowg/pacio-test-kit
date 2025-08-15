require_relative '../pacio_profiles'
require_relative '../test_helpers'

module PacioTestKit
  class MustSupportTest < Inferno::Test
    include PacioTestKit::PacioProfiles
    include PacioTestKit::TestHelpers

    title 'All must support elements are provided in the resources returned'
    id :pacio_resource_must_support

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
      PACIO_PROFILES[tag]
    end

    run do
      read_requests = load_tagged_requests(tag)
      search_requests = load_tagged_requests("#{tag}_Search")
      all_requests = read_requests + search_requests
      skip_if all_requests.blank?, "No #{tag} resource read/search request was made in previous tests as expected."

      successful_requests = all_requests.select { |request| request.status == 200 }
      skip_if successful_requests.empty?, "All #{tag} resource read/search requests were unsuccessful."

      base_resources = successful_requests.map(&:resource).compact
      targets = extract_target_resources(base_resources, resource_type)

      skip_if targets.empty?, "No #{tag} resources were found in the responses from previous read/search requests."

      assert_must_support_elements_present(targets, profile_url)
    end
  end
end
