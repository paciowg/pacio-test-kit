require_relative '../search_test'

module PacioTestKit
  class PatientGenderSearchTest < Inferno::Test
    include PacioTestKit::SearchTest

    title 'Server returns valid results for search by gender'
    description %(
      A server SHALL support searching by gender.
      This test will pass if resources are returned and match the search criteria. If
      none are returned, the test is skipped.
    )

    id :patient_gender_search_test

    def tag
      config.options[:profile]
    end

    def self.properties
      @properties ||= SearchTestProperties.new(
        resource_type: config.options[:resource_type],
        search_params: [
          { name: 'gender', paths: ['gender'] }
        ],
        token_search_params: [{ name: 'gender', paths: ['gender'] }]
      )
    end

    run do
      run_search_test
    end
  end
end
