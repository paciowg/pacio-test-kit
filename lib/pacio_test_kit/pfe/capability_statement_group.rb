module PacioTestKit
  module PFE
    class CapabilityStatementGroup < Inferno::TestGroup
      title 'Capability Statement'
      id :pacio_pfe_capability_statement
      short_description %(
        Retrieve information about supported server functionality using the FHIR capabilties interaction.
      )
      description 'TODO: Add description.'
      run_as_group
    end
  end
end
