require_relative '../common_tests/read_test'
require_relative '../common_tests/validation_test'
require_relative '../pacio_profiles'

module PacioTestKit
  module ADI
    class PACPCompositionGroup < Inferno::TestGroup
      include PacioTestKit::PacioProfiles

      title 'ADI PACP Composition Tests'
      id :pacio_adi_pacp_composition
      description %(
        Verify support for the server capabilities required by the
        PACIO ADI Personal Advance Care Plan Composition Profile
      )
      optional

      config options: {
        resource_type: 'Composition',
        profile: 'ADIPACPComposition'
      }
      run_as_group
      input_order :url

      test from: :pacio_resource_read,
           title: 'Server returns correct Composition resource from read interaction',
           optional: true,
           config: {
             inputs: {
               resource_ids: {
                 name: :pacp_composition_resource_ids,
                 optional: true,
                 title: 'ID(s) for ADIPACPComposition resources present on the server'
               }
             }
           }
      test from: :pacio_resource_validation,
           title: 'Composition Resources returned in previous tests conform to the ADIPACPComposition profile',
           description: ERB.new(File.read(File.expand_path(
                                            '../../docs/validation_test_description.md.erb', __dir__
                                          ))).result_with_hash(
                                            config:,
                                            pacio_profiles: PACIO_PROFILES
                                          )
    end
  end
end
