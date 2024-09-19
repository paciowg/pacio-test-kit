require_relative '../common_tests/read_test'
require_relative '../common_tests/validation_test'
require_relative '../pacio_profiles'

module PacioTestKit
  module ADI
    class PMOHospiceObservationGroup < Inferno::TestGroup
      include PacioTestKit::PacioProfiles

      title 'ADI PMO Hospice Observation Tests'
      id :pacio_adi_pmo_hospice_observation
      description %(
        Verify support for the server capabilities required by the
        PACIO ADI PMO Hospice Observation Profile
      )
      optional

      config options: {
        resource_type: 'Observation',
        profile: 'ADIPMOHospiceObservation'
      }
      run_as_group
      input_order :url

      test from: :pacio_resource_read,
           title: 'Server returns correct Observation resource from read interaction',
           optional: true,
           config: {
             inputs: {
               resource_ids: {
                 name: :pmo_hospice_observation_resource_ids,
                 optional: true,
                 title: 'ID(s) for ADIPMOHospiceObservation resources present on the server'
               }
             }
           }
      test from: :pacio_resource_validation,
           title: 'Observation Resources returned in previous tests conform to the ADIPMOHospiceObservation profile',
           description: ERB.new(File.read(File.expand_path(
                                            '../../docs/validation_test_description.md.erb', __dir__
                                          ))).result_with_hash(
                                            config:,
                                            pacio_profiles: PACIO_PROFILES
                                          )
    end
  end
end
