require_relative '../common_tests/read_test'
require_relative '../common_tests/validation_test'
require_relative '../pacio_profiles'

module PacioTestKit
  module ADI
    class ProvenanceGroup < Inferno::TestGroup
      include PacioTestKit::PacioProfiles

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
      test from: :pacio_resource_validation,
           title: 'Provenance Resources returned in previous tests conform to the ADIProvenance profile',
           description: ERB.new(File.read(File.expand_path(
                                            '../../docs/validation_test_description.md.erb', __dir__
                                          ))).result_with_hash(
                                            config:,
                                            pacio_profiles: PACIO_PROFILES
                                          )
    end
  end
end
