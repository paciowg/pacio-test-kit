require_relative '../interactions_test'

module PacioTestKit
  class SearchTypeTest < Inferno::Test
    include PacioTestKit::InteractionsTest

    title 'Resources can be correctly found with search-type interaction'
    id :pacio_resource_search_type
    description 'A server SHALL support the search-type interaction.'

    input :patient,
          title: 'The patient search-type parameter to find a resource on the server.'

    input :category,
          title: 'The category search-type parameter to find a resource on the server.'

    input :code,
          title: 'The code search-type parameter to find a resource on the server.'

    input :date,
          title: 'The date search-type parameter to find a resource on the server.'

    def resource_type
      config.options[:resource_type]
    end

    def tag
      config.options[:profile]
    end

    run do
      no_error_validation("Fail to find #{resource_type} resource(s) by search-type. See error messages for details.")
    end
  end
end
