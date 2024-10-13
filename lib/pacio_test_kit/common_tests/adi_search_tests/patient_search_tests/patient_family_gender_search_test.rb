require_relative '../../../searcht_test'

module PacioTestKit
  class PatientFamilyGenderSearchTest < Inferno::Test
    include PacioTestKit::SearchTest

    title 'Server returns valid results for search by family + gender'
    description %(
      A server SHALL support searching by family + gender.
      This test will pass if resources are returned and match the search criteria. If
      none are returned, the test is skipped.
    )

    id :patient_family_gender_search_test

    def tag
      config.options[:profile]
    end

    def self.properties
      @properties ||= SearchTestProperties.new(
        resource_type: config.options[:resource_type],
        search_params: [
          { name: 'family', paths: ['family'] },
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
