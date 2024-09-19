require_relative '../common_tests/read_test'

module PacioTestKit
  module ADI
    class OrganizationGroup < Inferno::TestGroup
      title 'Organization Tests'
      id :pacio_adi_organization
      description %(
        Verify support for the server capabilities required by the
        US Core Organization Profile
      )

      config options: {
        resource_type: 'Organization',
        profile: 'USCOREOrganization'
      }
      run_as_group
      input_order :url

      test from: :pacio_resource_read,
           title: 'Server returns correct Organization resource from read interaction',
           config: {
             inputs: {
               resource_ids: {
                 name: :organization_resource_ids,
                 title: 'ID(s) for Organization resources present on the server'
               }
             }
           }
    end
  end
end