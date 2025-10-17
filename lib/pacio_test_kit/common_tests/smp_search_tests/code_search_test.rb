# TODO: DELETE IF UNUSED
require_relative '../../search_test'

module PacioTestKit
  class CodeSearchTest < Inferno::Test
    include PacioTestKit::SearchTest

    title 'Server returns valid results for search by code'
    description %(
      A server SHALL support searching by code.
      This test will pass if resources are returned and match the search criteria. If
      none are returned, the test is skipped.
    )

    id :code_search_test

    def tag
      config.options[:profile]
    end

    def self.properties
      @properties ||= SearchTestProperties.new(
        resource_type: config.options[:resource_type],
        search_params: [{ name: 'code', paths: ['code'] }],
        token_search_params: [{ name: 'code', paths: ['code'] }]
      )
    end

    run do
      run_search_test
    end
  end
end
