require_relative '../common_tests/read_test'

module PacioTestKit
  module ADI
    class PersonalPrioritiesOrganizerGroup < Inferno::TestGroup
      title 'ADI Personal Priorities Organizer Tests'
      id :pacio_adi_personal_priorities_organizer
      description %(
        Verify support for the server capabilities required by the
        PACIO ADI Personal Priorities Organizer Profile
      )
      optional

      config options: {
        resource_type: 'List',
        profile: 'ADIPersonalPrioritiesOrganizer'
      }
      run_as_group
      input_order :url

      test from: :pacio_resource_read,
           title: 'Server returns correct List resource from read interaction',
           optional: true,
           config: {
             inputs: {
               resource_ids: {
                 name: :personal_priorities_organizer_resource_ids,
                 optional: true,
                 title: 'ID(s) for ADIPersonalPrioritiesOrganizer resources present on the server'
               }
             }
           }
    end
  end
end
