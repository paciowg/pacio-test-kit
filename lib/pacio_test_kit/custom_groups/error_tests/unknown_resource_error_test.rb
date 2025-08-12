module PacioTestKit
  class UnknownResourceErrorTest < Inferno::Test
    title 'Server returns 404 response when making a read request to an unknown resource.'
    id :pacio_unknown_resource_error
    description %(
      This test verifies that a server returns a 404 response when
      attempting to read an unknown/non-existent resource.

      The test will attempt to read a Patient resource with a randomly generated ID prefixed with "unknown-patient-".
      The expected outcome is a 404 status code, indicating that the resource does not exist,
      and the response should be of type `OperationOutcome`.
    )

    run do
      patient_id = "unknown-patient-#{SecureRandom.uuid}"
      fhir_read('Patient', patient_id)
      assert_response_status(404)
      assert_resource_type('OperationOutcome')
    end
  end
end
