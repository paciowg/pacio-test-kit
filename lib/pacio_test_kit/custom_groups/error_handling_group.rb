require_relative 'error_tests/invalid_parameter_error_test'
require_relative 'error_tests/unknown_resource_error_test'
require_relative 'error_tests/unauthorized_request_error_test'

module PacioTestKit
  class ErrorHandlingGroup < Inferno::TestGroup
    title 'Error Handling Tests'
    id :pacio_error_handling
    description %(
      This test group verifies that a FHIR server conformant to this IG can properly respond to malformed requests.
      It includes tests for handling invalid parameters, unknown resources, and unauthorized requests.

      Per the FHIR specification, this group of tests ensures that the server returns the following responses classes:
        - (Status 400): invalid parameter
        - (Status 401/4xx): unauthorized request
        - (Status 404): unknown resource
    )
    input_order :url

    test from: :pacio_invalid_parameter_error
    test from: :pacio_unknown_resource_error
    test from: :pacio_unauthorized_request_error
  end
end
