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
      run_as_group
    end
  end
end
