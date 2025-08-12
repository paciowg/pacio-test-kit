module PacioTestKit
  class InvalidParameterErrorTest < Inferno::Test
    title 'Server returns 400 response when providing invalid parameter to search request.'
    id :pacio_invalid_parameter_error
    description %(
      This test verifies that a server returns a 400 response when
      attempting to search resource and providing an invalid search parameter.
    )

    input :search_method,
          title: 'Search Method',
          description: 'Method to use for the search request. Defaults to GET.',
          type: 'radio',
          options: {
            list_options: [
              { label: 'GET', value: 'get' },
              { label: 'POST', value: 'post' }
            ]
          },
          default: 'get'

    run do
      if search_method == 'get'
        fhir_search('Patient', params: { 'unknownParam' => 'unknown' })
        assert_response_status(400)
        assert_resource_type('OperationOutcome')
      else
        fhir_search('Patient', params: { 'unknownParam' => 'unknown' }, search_method: :post)
        assert_response_status(400)
        assert_resource_type('OperationOutcome')
      end
    end
  end
end
