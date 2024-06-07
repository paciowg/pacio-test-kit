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
      run_as_group
    end
  end
end
