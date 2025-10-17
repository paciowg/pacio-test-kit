require_relative '../pacio_profiles'

module PacioTestKit
  module SMP
    class BundleTransactionGroup < Inferno::TestGroup
      include PacioTestKit::PacioProfiles

      title 'SMP Bundle Transaction Tests'
      id :pacio_smp_bundle_transaction
      short_description %(
        Verify support for the server capabilities required by the FHIR Bundle resource type.
      )
      description %(
      )
      # description adapted from US-Core-Test-Kit groups: https://github.com/inferno-framework/us-core-test-kit

      optional
      config options: {
        resource_type: 'Bundle',
        profile: 'SMPBundleTransaction'
      }
      run_as_group
      input_order :url

      test from: :pacio_resource_create,
           title: 'Server creates correct Bundle resource from Bundle create interaction',
           config: {
             inputs: {
               resource_input: {
                 name: :bundle_transaction_resource_input,
                 type: 'textarea',
                 title: 'SMPBundleTransaction resource to create on the server.'
               }
             }
           }

      test from: :pacio_resource_read,
           title: 'Server returns correct Bundle resource from Bundle read interaction',
           config: {
             inputs: {
               resource_ids: {
                 name: :bundle_transaction_resource_ids,
                 optional: true,
                 title: 'ID(s) for SMPBundleTransaction resources present on the server.',
                 description: 'If providing multiple IDs, separate them by a comma and a space. ' \
                              'e.g. id_1, id_2, id_3. If leaving blank, test will use the resource id from ' \
                              'Bundle resource created by previous test.'
               }
             }
           }
    end
  end
end
