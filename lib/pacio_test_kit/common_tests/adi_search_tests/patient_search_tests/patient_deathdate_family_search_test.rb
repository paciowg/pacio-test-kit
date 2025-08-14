require_relative '../../../search_test'

module PacioTestKit
  class PatientDeathdateFamilySearchTest < Inferno::Test
    include PacioTestKit::SearchTest

    title 'Server returns valid results for search by deathdate + family'
    description %(
      A server SHOULD support searching by deathdate + family.
      This test will pass if resources are returned and match the search criteria. If
      none are returned, the test is skipped.
    )
    optional

    id :patient_deathdate_family_search_test

    def tag
      config.options[:profile]
    end

    def self.properties
      @properties ||= SearchTestProperties.new(
        resource_type: config.options[:resource_type],
        search_params: [
          { name: 'death-date', paths: ['deceased'] },
          { name: 'family', paths: ['name.family'] }
        ]
      )
    end

    run do
      run_search_test
    end
  end
end
