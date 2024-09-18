require_relative '../common_tests/read_test'

module PacioTestKit
  module ADI
    class OrganDonationObservationGroup < Inferno::TestGroup
      title 'ADI Organ Donation Observation Tests'
      id :pacio_adi_organ_donation_observation
      description %(
        Verify support for the server capabilities required by the
        PACIO ADI Organ Donation Observation Profile
      )
      optional

      config options: {
        resource_type: 'Observation',
        profile: 'ADIOrganDonationObservation'
      }
      run_as_group
      input_order :url

      test from: :pacio_resource_read,
           title: 'Server returns correct Observation resource from read interaction',
           optional: true,
           config: {
             inputs: {
               resource_ids: {
                 name: :organ_donation_observation_resource_ids,
                 optional: true,
                 title: 'ID(s) for ADIOrganDonationObservation resources present on the server'
               }
             }
           }
    end
  end
end
