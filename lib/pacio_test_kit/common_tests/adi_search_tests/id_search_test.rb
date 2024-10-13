require_relative '../../searcht_test'

module PacioTestKit
  class IdSearchTest < Inferno::Test
    include PacioTestKit::SearchTest

    title 'Server returns valid results for search by id'
    description %(
      A server SHALL support searching by id.
      This test will pass if resources are returned and match the search criteria. If
      none are returned, the test is skipped.
    )

    id :id_search_test

    def tag
      config.options[:profile]
    end

    def self.properties
      @properties ||= SearchTestProperties.new(
        resource_type: config.options[:resource_type],
        search_params: [
          { name: 'id', paths: ['id'] } # TODO: VID
        ]
      )
    end

    run do
      run_search_test
    end
  end
end