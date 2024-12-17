require_relative '../../../searcht_test'

module PacioTestKit
  class DocumentReferencePeriodSearchTest < Inferno::Test
    include PacioTestKit::SearchTest

    title 'Server returns valid results for search by period'
    description %(
      A server SHALL support searching by period.
      This test will pass if resources are returned and match the search criteria. If
      none are returned, the test is skipped.
    )

    id :document_ref_period_search_test

    def tag
      config.options[:profile]
    end

    def self.properties
      @properties ||= SearchTestProperties.new(
        resource_type: config.options[:resource_type],
        search_params: [
          { name: 'period', paths: ['period'] }
        ]
      )
    end

    run do
      run_search_test
    end
  end
end
