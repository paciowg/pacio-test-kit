module PacioTestKit
  class StatusSearchTypeTest < Inferno::Test
    title 'Resource can be found with search-type interaction by status'
    id :pacio_status_search_type
    description 'A server SHALL support the search-type interaction.'
    # optional true

    def resource_type
      config.options[:resource_type]
    end

    def tag
      config.options[:profile]
    end

    run do
      # TODO
    end
  end
end