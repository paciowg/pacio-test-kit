module PacioTestKit
  class DeletedResourceErrorTest < Inferno::Test
    title 'Server returns 410 response when making a read request to a deleted resource.'
    id :pacio_deleted_resource_error
    description %(
      This test verifies that a server returns a 410 response when
      attempting to read a deleted resource.
    )
    input :deleted_resource_id,
          title: 'ID for a deleted resource from the server for deleted resource error testing'

    input :deleted_resource_type,
          title: 'Resource type for the deleted resource from the server for deleted resource error testing'

    # This test does not align with the FHIR Specification (http://hl7.org/fhir/http.html#delete)
    # “For security reasons, the server may return other status codes as defined under Access Denied Response Handling.”
    # This test has been removed from the PACIO Error Test Group.
    # It can be added manually to a specific test suite if required.
    run do
      skip_if deleted_resource_id.blank? || deleted_resource_type.blank?,
              'No deleted resource ID or resource type provided'

      fhir_read(deleted_resource_type.strip, deleted_resource_id.strip)
      assert_response_status(410)
      assert_resource_type('OperationOutcome')
    end
  end
end
