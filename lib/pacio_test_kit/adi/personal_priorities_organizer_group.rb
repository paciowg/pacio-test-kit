require_relative '../common_tests/read_test'
require_relative '../common_tests/validation_test'
require_relative '../pacio_profiles'

module PacioTestKit
  module ADI
    class PersonalPrioritiesOrganizerGroup < Inferno::TestGroup
      include PacioTestKit::PacioProfiles

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
                 title: 'ID(s) for ADIPersonalPrioritiesOrganizer List resources present on the server'
               }
             }
           }
      test from: :pacio_resource_validation,
           title: 'List Resources returned in previous tests conform to the ADIPersonalPrioritiesOrganizer profile',
           description: ERB.new(File.read(File.expand_path(
                                            '../../docs/validation_test_description.md.erb', __dir__
                                          ))).result_with_hash(
                                            config:,
                                            pacio_profiles: PACIO_PROFILES
                                          )
    end
  end
end
