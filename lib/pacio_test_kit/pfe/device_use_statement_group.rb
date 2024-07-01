require_relative '../common_tests/read_test'
require_relative '../common_tests/create_test'

module PacioTestKit
  module PFE
    class DeviceUseStatementGroup < Inferno::TestGroup
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

      test from: :pacio_resource_create,
           title: 'Server creates correct DeviceUseStatement resource from DeviceUseStatement create interaction',
           config: {
             inputs: {
               resource_inputs: {
                 name: :device_use_statement_resource_list,
                 title: 'Resources(s) for PFEUseOfDevice resources created on the server'
               }
             }
           }
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
    end
  end
end
