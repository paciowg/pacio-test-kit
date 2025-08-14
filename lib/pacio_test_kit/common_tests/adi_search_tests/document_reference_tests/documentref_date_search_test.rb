require_relative '../../../search_test'

module PacioTestKit
  class DocumentReferenceDateSearchTest < Inferno::Test
    include PacioTestKit::SearchTest

    title 'Server returns valid results for search by date'
    description %(
      A server SHALL support searching by date.
      This test will pass if resources are returned and match the search criteria. If
      none are returned, the test is skipped.
    )

    id :document_ref_date_search_test

    def tag
      config.options[:profile]
    end

    def self.properties
      @properties ||= SearchTestProperties.new(
        resource_type: config.options[:resource_type],
        search_params: [
          { name: 'date', paths: ['date'] }
        ]
      )
    end

    run do
      run_search_test
    end
  end
end
