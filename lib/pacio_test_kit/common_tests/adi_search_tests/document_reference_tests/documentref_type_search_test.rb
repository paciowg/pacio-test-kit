require_relative '../../../searcht_test'

module PacioTestKit
  class DocumentReferenceTypeSearchTest < Inferno::Test
    include PacioTestKit::SearchTest

    title 'Server returns valid results for search by type'
    description %(
      A server SHALL support searching by type.
      This test will pass if resources are returned and match the search criteria. If
      none are returned, the test is skipped.
    )

    id :document_ref_type_search_test

    def tag
      config.options[:profile]
    end

    def self.properties
      @properties ||= SearchTestProperties.new(
        resource_type: config.options[:resource_type],
        search_params: [
          { name: 'type', paths: ['type'] }
        ],
        token_search_params: [{ name: 'type', paths: ['type'] }]
      )
    end

    run do
      run_search_test
    end
  end
end
