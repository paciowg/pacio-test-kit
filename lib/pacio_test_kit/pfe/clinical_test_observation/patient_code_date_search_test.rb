require_relative '../common_tests/search_test'

module PacioTestKit
  class PatientCodeDateSearchTest < Inferno::Test
    include PacioTestKit::SearchTest

    title 'Server returns valid results for search by patient + code + date'
    description %(
      A server SHALL support searching by patient + code + date.
      This test will pass if resources are returned and match the search criteria. If
      none are returned, the test is skipped.
    )

    id :patient_code_date_search_test

    def tag
      config.options[:profile]
    end

    def self.properties
      @properties ||= SearchTestProperties.new(
        resource_type: config.options[:resource_type],
        search_params: [
          { name: 'patient', paths: ['subject'] },
          { name: 'code', paths: ['code'] },
          { name: 'date', paths: ['effective'] }
        ],
        token_search_params: [{ name: 'code', paths: ['code'] }]
      )
    end

    run do
      run_search_test
    end
  end
end
