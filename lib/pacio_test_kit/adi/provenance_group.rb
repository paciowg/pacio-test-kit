require_relative '../common_tests/read_test'

module PacioTestKit
  module ADI
    class ProvenanceGroup < Inferno::TestGroup
      title 'ADI Provenance Tests'
      id :pacio_adi_provenance
      description %(
        Verify support for the server capabilities required by the
        PACIO ADI Provenance Profile
      )
      optional

      config options: {
        resource_type: 'Provenance',
        profile: 'ADIProvenance'
      }
      run_as_group
      input_order :url

      test from: :pacio_resource_read,
           title: 'Server returns correct Provenance resource from read interaction',
           optional: true,
           config: {
             inputs: {
               resource_ids: {
                 name: :provenance_resource_ids,
                 optional: true,
                 title: 'ID(s) for ADIProvenance resources present on the server'
               }
             }
           }
    end
  end
end
