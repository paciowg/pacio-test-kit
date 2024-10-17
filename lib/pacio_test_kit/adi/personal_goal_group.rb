require_relative '../common_tests/read_test'
require_relative '../common_tests/validation_test'
require_relative '../pacio_profiles'

module PacioTestKit
  module ADI
    class PersonalGoalGroup < Inferno::TestGroup
      include PacioTestKit::PacioProfiles

      title 'ADI Personal Goal Tests'
      id :pacio_adi_personal_goal
      description %(
        Verify support for the server capabilities required by the
        PACIO ADI Personal Goal Profile
      )
      optional

      config options: {
        resource_type: 'Goal',
        profile: 'ADIPersonalGoal'
      }
      run_as_group
      input_order :url

      test from: :pacio_resource_read,
           title: 'Server returns correct Goal resource from read interaction',
           optional: true,
           config: {
             inputs: {
               resource_ids: {
                 name: :personal_goal_resource_ids,
                 optional: true,
                 title: 'ID(s) for ADIPersonalGoal resources present on the server'
               }
             }
           }
      test from: :pacio_resource_validation,
           title: 'Goal Resources returned in previous tests conform to the ADIPersonalGoal profile',
           description: ERB.new(File.read(File.expand_path(
                                            '../../docs/validation_test_description.md.erb', __dir__
                                          ))).result_with_hash(
                                            config:,
                                            pacio_profiles: PACIO_PROFILES
                                          )
    end
  end
end
