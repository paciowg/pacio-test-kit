require_relative '../common_tests/read_test'
require_relative '../common_tests/validation_test'
require_relative '../pacio_profiles'

module PacioTestKit
  module PFE
    class ServiceRequestGroup < Inferno::TestGroup
      include PacioTestKit::PacioProfiles

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
      input_order :url

      test from: :pacio_resource_read,
           title: 'Server returns correct ServiceRequest resource from ServiceRequest read interaction',
           optional: true,
           config: {
             inputs: {
               resource_ids: {
                 name: :service_request_resource_ids,
                 optional: true,
                 title: 'ID(s) for PFEServiceRequest resources present on the server'
               }
             }
           }
      test from: :pacio_resource_validation,
           title: 'ServiceRequest Resources returned in previous tests conform to the PFEServiceRequest profile',
           description: ERB.new(File.read(File.expand_path(
                                            '../../docs/validation_test_description.md.erb', __dir__
                                          ))).result_with_hash(
                                            config:,
                                            pacio_profiles: PACIO_PROFILES
                                          )
    end
  end
end
