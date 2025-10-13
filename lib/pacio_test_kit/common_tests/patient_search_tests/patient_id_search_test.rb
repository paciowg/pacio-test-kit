require_relative '../search_test'

module PacioTestKit
  class PatientIdSearchTest < Inferno::Test
    include PacioTestKit::SearchTest

    title 'Server returns valid results for search by id'
    description %(
      A server SHALL support searching by id.
      This test will pass if resources are returned and match the search criteria. If
      none are returned, the test is skipped.
    )

    id :patient_id_search_test

    def tag
      config.options[:profile]
    end

    def self.properties
      @properties ||= SearchTestProperties.new(
        resource_type: config.options[:resource_type],
        search_params: [
          { name: '_id', paths: ['id'] }
        ]
      )
    end

    run do
      run_search_test
    end
  end
end
