require_relative '../pacio_test_kit/custom_groups/error_tests/invalid_parameter_error_test'
require_relative '../pacio_test_kit/custom_groups/error_tests/unknown_resource_error_test'
require_relative '../pacio_test_kit/custom_groups/error_tests/deleted_resource_error_test'
require_relative '../pacio_test_kit/custom_groups/error_tests/unauthorized_request_error_test'

module PacioTestKit
  class ErrorHandlingGroup < Inferno::TestGroup
    title 'Error Handling Tests'
    id :pacio_error_handling
    short_description 'Verify PFE server can properly respond to malformed requests.'
    run_as_group
    input_order :url

    test from: :pacio_invalid_parameter_error
    test from: :pacio_unknown_resource_error,
         config: {
           inputs: {
             resource_ids: {
               name: :resource_ids,
               title: 'ID(s) for resources unknown to the server'
             },
             resource_types: {
               name: :resource_types,
               title: 'Type(s) for resources unknown to the server'
             }
           }
         }
    test from: :pacio_deleted_resource_error,
         config: {
           inputs: {
             resource_ids: {
               name: :resource_ids,
               title: 'ID(s) for resources deleted from the server'
             },
             resource_types: {
               name: :resource_types,
               title: 'Type(s) for resources deleted from the server'
             }
           }
         }
    test from: :pacio_unauthorized_request_error,
         config: {
           inputs: {
             resource_ids: {
               name: :resource_ids,
               title: 'ID(s) for resources present on the server'
             },
             resource_types: {
               name: :resource_types,
               title: 'Type(s) for resources present on the server'
             }
           }
         }
  end
end
