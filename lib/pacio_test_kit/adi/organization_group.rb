require_relative '../common_tests/read_test'
require_relative '../common_tests/validation_test'
require_relative '../pacio_profiles'
require_relative '../common_tests/adi_search_tests/id_search_test'

module PacioTestKit
  module ADI
    class OrganizationGroup < Inferno::TestGroup
      include PacioTestKit::PacioProfiles

      title 'Organization Tests'
      id :pacio_adi_organization
      description %(
        Verify support for the server capabilities required by the
        US Core Organization Profile
      )

      config options: {
        resource_type: 'Organization',
        profile: 'USCoreOrganization'
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
      test from: :id_search_test,
           title: 'Server returns valid results for Organization search by id'
      test from: :pacio_resource_validation,
           title: 'Organization Resources returned in previous tests conform to the US Core Organization profile',
           description: ERB.new(File.read(File.expand_path(
                                            '../../docs/validation_test_description.md.erb', __dir__
                                          ))).result_with_hash(
                                            config:,
                                            pacio_profiles: PACIO_PROFILES
                                          )
    end
  end
end
