module PacioTestKit
  class UnauthorizedRequestErrorTest < Inferno::Test
    title 'Server returns 401, 403, or 404 response when making unauthorized request.'
    id :pacio_unauthorized_request_error
    description %(
      This test verifies that a protected FHIR server returns a 401, 403, or 404 response when
      attempting to make an unauthorized request (i.e. a request without proper authentication/authorization).

      Tester should provide the ID of an existing patient resource to retrieve for unauthorized request testing, with
      invalid or no authentication credentials.
      The test will attempt to read a patient resource from the provided protected FHIR server endpoint with
      the invalid or no authentication credentials. The expected outcome is that the server responds with a 401 (Unauthorized),
      403 (Forbidden), or 404 (Not Found) status code, indicating that the request was unauthorized.
      Also, the response should include an OperationOutcome resource providing additional information about the error.
    )
    input :unauthorized_patient_id,
          title: 'ID of an existing patient resource to retrieve for unauthorized request testing'

    run do
      fhir_read('Patient', unauthorized_patient_id)
      assert_response_status([401, 403, 404])
      assert_resource_type('OperationOutcome')
    end
  end
end
