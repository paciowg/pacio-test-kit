module PacioTestKit
  module PFE
    class CollectionObservationGroup < Inferno::TestGroup
      title 'Collection Observation Tests'
      id :pacio_pfe_collection_observation
      short_description %(
        Verify support for the server capabilities required by the PACIO PFE Collection Profile.
      )
      description 'TODO: Add description.'
      run_as_group
    end
  end
end
