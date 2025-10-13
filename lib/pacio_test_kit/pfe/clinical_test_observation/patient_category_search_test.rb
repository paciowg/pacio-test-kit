require_relative '../common_tests/search_test'

module PacioTestKit
  class PatientCategorySearchTest < Inferno::Test
    include PacioTestKit::SearchTest

    title 'Server returns valid results for search by patient + category'
    description %(
      A server SHALL support searching by patient + category.
      This test will pass if resources are returned and match the search criteria. If
      none are returned, the test is skipped.
    )

    id :patient_category_search_test

    def tag
      config.options[:profile]
    end

    def self.properties
      @properties ||= SearchTestProperties.new(
        resource_type: config.options[:resource_type],
        search_params: [
          { name: 'patient', paths: ['subject'] },
          { name: 'category', paths: ['category'] }
        ],
        token_search_params: [{ name: 'category', paths: ['category'] }]
      )
    end

    run do
      run_search_test
    end
  end
end
