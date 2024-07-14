require_relative '../common_tests/read_test'
require_relative '../common_tests/validation_test'
require_relative '../pacio_profiles'

module PacioTestKit
  module PFE
    class DeviceUseStatementGroup < Inferno::TestGroup
      include PacioTestKit::PacioProfiles

      title 'DeviceUseStatement Tests'
      id :pacio_pfe_device_use_statement
      short_description %(
        Verify support for the server capabilities required by the PACIO PFE Use of Device Profile.
      )
      description 'TODO: Add description'
      optional

      config options: {
        resource_type: 'DeviceUseStatement',
        profile: 'PFEUseOfDevice'
      }
      run_as_group
      input_order :url

      test from: :pacio_resource_read,
           title: 'Server returns correct DeviceUseStatement resource from DeviceUseStatement read interaction',
           optional: true,
           config: {
             inputs: {
               resource_ids: {
                 name: :device_use_statement_resource_ids,
                 title: 'ID(s) for PFEUseOfDevice resources present on the server'
               }
             }
           }
      test from: :pacio_resource_validation,
           title: 'DeviceUseStatement Resources returned in previous tests conform to the PFEUseOfDevice profile',
           description: ERB.new(File.read(File.join(
                                            'lib', 'docs', 'validation_test_description.md.erb'
                                          ))).result_with_hash(
                                            config:,
                                            pacio_profiles: PACIO_PROFILES
                                          )
    end
  end
end
