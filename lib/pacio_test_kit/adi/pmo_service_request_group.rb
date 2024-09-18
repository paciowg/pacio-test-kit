require_relative '../common_tests/read_test'

module PacioTestKit
  module ADI
    class PMOServiceRequestGroup < Inferno::TestGroup
      title 'ADI PMO Service Request Tests'
      id :pacio_adi_pmo_service_request
      description %(
        Verify support for the server capabilities required by the
        PACIO ADI PMO Service Request Profile
      )
      optional

      config options: {
        resource_type: 'ServiceRequest',
        profile: 'ADIPMOServiceRequest'
      }
      run_as_group
      input_order :url

      test from: :pacio_resource_read,
           title: 'Server returns correct ServiceRequest resource from read interaction',
           optional: true,
           config: {
             inputs: {
               resource_ids: {
                 name: :pmo_service_request_resource_ids,
                 optional: true,
                 title: 'ID(s) for ADIPMOServiceRequest resources present on the server'
               }
             }
           }
    end
  end
end
