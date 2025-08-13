require_relative '../../search_test'

module PacioTestKit
  class PatientCodeSearchTest < Inferno::Test
    include PacioTestKit::SearchTest

    title 'Server returns valid results for search by patient + code'
    description %(
      A server SHALL support searching by patient + code.
      This test will pass if resources are returned and match the search criteria. If
      none are returned, the test is skipped.
    )

    id :patient_code_search_test

    def tag
      config.options[:profile]
    end

    def self.properties
      @properties ||= SearchTestProperties.new(
        resource_type: config.options[:resource_type],
        search_params: [
          { name: 'patient', paths: ['subject'] },
          { name: 'code', paths: ['code'] }
        ],
        token_search_params: [{ name: 'code', paths: ['code'] }]
      )
    end

    run do
      run_search_test
    end
  end
end
