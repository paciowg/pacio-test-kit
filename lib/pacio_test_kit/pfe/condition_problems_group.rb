require_relative '../common_tests/read_test'

module PacioTestKit
  module PFE
    class ConditionProblemsGroup < Inferno::TestGroup
      title 'Condition Problems Tests'
      id :pacio_pfe_condition_problems
      short_description %(
        Verify support for the server capabilities required by the PACIO PFE Condition Problems
        and Health Concerns Profile.
      )
      description 'TODO: Add description.'
      optional

      config options: {
        resource_type: 'Condition',
        profile: 'PFEConditionProblemsHealthConcerns'
      }
      run_as_group

      test from: :pacio_resource_read,
           title: 'Server returns correct Condition resource from Condition read interaction',
           config: {
             inputs: {
               resource_ids: {
                 name: :condition_problems_resource_ids,
                 title: 'ID(s) for PFEConditionProblemsHealthConcerns resources present on the server'
               }
             }
           }
    end
  end
end
