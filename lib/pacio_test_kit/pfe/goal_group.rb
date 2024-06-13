require_relative '../common_tests/read_test'

module PacioTestKit
  module PFE
    class GoalGroup < Inferno::TestGroup
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

      test from: :pacio_resource_read,
           title: 'Server returns correct Goal resource from Goal read interaction',
           config: {
             inputs: {
               resource_ids: {
                 name: :goal_resource_ids,
                 title: 'ID(s) for PFEGoal resources present on the server'
               }
             }
           }
    end
  end
end
