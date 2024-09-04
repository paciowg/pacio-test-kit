module PacioTestKit
  class InvalidParameterErrorTest < Inferno::Test
    title 'Server returns 400 response when providing invalid parameter to search request.'
    id :pacio_invalid_parameter_error
    description %(
      This test verifies that a server returns a 400 response when
      attempting to search resource and providing an invalid parameter.
    )

    run do
      fhir_search('Observation', params: { 'unknownParam' => 'unknown' })
      assert_response_status(400)
      assert_resource_type('OperationOutcome')
    end
  end
end
