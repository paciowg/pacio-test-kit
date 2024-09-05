require_relative '../../searcht_test'

module PacioTestKit
  class PatientSearchTest < Inferno::Test
    include PacioTestKit::SearchTest

    title 'Server returns valid results for search by patient'
    description %(
      A server SHALL support searching by patient.
      This test will pass if resources are returned and match the search criteria. If
      none are returned, the test is skipped.

      This test verifies that the server supports searching by reference using
      the form `patient=[id]` as well as `patient=Patient/[id]`. The two
      different forms are expected to return the same number of results.

      Additionally, this test will check that GET and POST search methods
      return the same number of results. Search by POST is required by the
      FHIR R4 specification.
    )

    id :patient_search_test

    def tag
      config.options[:profile]
    end

    def self.properties
      @properties ||= SearchTestProperties.new(
        resource_type: config.options[:resource_type],
        search_params: [{ name: 'patient', paths: ['subject'] }],
        test_reference_variants: true,
        test_post_search: true
      )
    end

    run do
      run_search_test
    end
  end
end
