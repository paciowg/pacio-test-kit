require_relative '../common_tests/read_test'
require_relative '../common_tests/validation_test'
require_relative '../pacio_profiles'

module PacioTestKit
  module ADI
    class CompositionHeaderGroup < Inferno::TestGroup
      include PacioTestKit::PacioProfiles

      title 'ADI Composition Header Tests'
      id :pacio_adi_composition_header
      description 'Verify support for the server capabilities required by the PACIO ADI Composition Header Profile'
      optional

      config options: {
        resource_type: 'Composition',
        profile: 'ADICompositionHeader'
      }
      run_as_group
      input_order :url

      test from: :pacio_resource_read,
           title: 'Server returns correct Composition resource from read interaction',
           optional: true,
           config: {
             inputs: {
               resource_ids: {
                 name: :composition_header_resource_ids,
                 optional: true,
                 title: 'ID(s) for ADICompositionHeader resources present on the server'
               }
             }
           }
      test from: :pacio_resource_validation,
           title: 'Composition Resources returned in previous tests conform to the ADICompositionHeader profile',
           description: ERB.new(File.read(File.expand_path(
                                            '../../docs/validation_test_description.md.erb', __dir__
                                          ))).result_with_hash(
                                            config:,
                                            pacio_profiles: PACIO_PROFILES
                                          )
    end
  end
end
