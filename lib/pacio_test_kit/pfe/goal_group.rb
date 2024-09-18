require_relative '../common_tests/read_test'
require_relative '../common_tests/validation_test'
require_relative '../pacio_profiles'

module PacioTestKit
  module PFE
    class GoalGroup < Inferno::TestGroup
      include PacioTestKit::PacioProfiles

      title 'Goal Tests'
      id :pacio_pfe_goal
      short_description %(
        Verify support for the server capabilities required by the PACIO PFE Goal Profile.
      )
      description 'TODO: Add description.'
      optional

      config options: {
        resource_type: 'Goal',
        profile: 'PFEGoal'
      }
      run_as_group
      input_order :url

      test from: :pacio_resource_read,
           title: 'Server returns correct Goal resource from Goal read interaction',
           optional: true,
           config: {
             inputs: {
               resource_ids: {
                 name: :goal_resource_ids,
                 optional: true,
                 title: 'ID(s) for PFEGoal resources present on the server'
               }
             }
           }
      test from: :pacio_resource_validation,
           title: 'Goal Resources returned in previous tests conform to the PFEGoal profile',
           description: ERB.new(File.read(File.join(
                                            'lib', 'docs', 'validation_test_description.md.erb'
                                          ))).result_with_hash(
                                            config:,
                                            pacio_profiles: PACIO_PROFILES
                                          )
    end
  end
end
