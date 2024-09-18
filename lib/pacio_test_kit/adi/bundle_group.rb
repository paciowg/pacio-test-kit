require_relative '../common_tests/read_test'

module PacioTestKit
  module ADI
    class BundleGroup < Inferno::TestGroup
      title 'Bundle Tests'
      id :pacio_adi_bundle
      description 'Verify ADI server support for the Bundle resource'

      config options: {
        resource_type: 'Bundle',
        profile: 'Bundle'
      }
      run_as_group
      input_order :url

      test from: :pacio_resource_read,
           title: 'Server returns correct Bundle resource from read interaction',
           config: {
             inputs: {
               resource_ids: {
                 name: :bundle_resource_ids,
                 title: 'ID(s) for Bundle resources present on the server'
               }
             }
           }
    end
  end
end
