require_relative '../custom_groups/error_tests/invalid_parameter_error_test'
require_relative '../custom_groups/error_tests/unknown_resource_error_test'
require_relative '../custom_groups/error_tests/deleted_resource_error_test'
module PacioTestKit
  module PFE
    class ErrorHandlingGroup < Inferno::TestGroup
      title 'Error Handling Tests'
      id :pacio_pfe_error_handling
      short_description 'Verify PFE server can properly malformed requests.'
      run_as_group
      input_order :url

      test from: :pacio_invalid_parameter_error
      test from: :pacio_unknown_resource_error,
           config: {
             inputs: {
               resource_ids: {
                 name: :unknown_resource_ids,
                 title: 'ID(s) for resources present on the server'
               },
               resource_types: {
                 name: :unknown_resource_types,
                 title: 'Type(s) for resources present on the server'
               }
             }
           }
      test from: :pacio_deleted_resource_error,
           config: {
             inputs: {
               resource_ids: {
                 name: :unknown_resource_ids,
                 title: 'ID(s) for resources present on the server'
               },
               resource_types: {
                 name: :unknown_resource_types,
                 title: 'Type(s) for resources present on the server'
               }
             }
           }
    end
  end
end
