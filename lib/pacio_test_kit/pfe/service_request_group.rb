require_relative '../common_tests/read_test'

module PacioTestKit
  module PFE
    class ServiceRequestGroup < Inferno::TestGroup
      title 'ServiceRequest Tests'
      id :pacio_pfe_service_request
      short_description %(
        Verify support for the server capabilities required by the PACIO PFE Service Request Profile.
      )
      description 'TODO: Add description.'
      optional

      config options: {
        resource_type: 'ServiceRequest',
        profile: 'PFEServiceRequest'
      }
      run_as_group

      test from: :pacio_resource_read,
           title: 'Server returns correct ServiceRequest resource from ServiceRequest read interaction',
           config: {
             inputs: {
               resource_ids: {
                 name: :service_request_resource_ids,
                 title: 'ID(s) for PFEServiceRequest resources present on the server'
               }
             }
           }
    end
  end
end
