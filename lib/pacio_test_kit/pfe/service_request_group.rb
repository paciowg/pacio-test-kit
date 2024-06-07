module PacioTestKit
  module PFE
    class ServiceRequestGroup < Inferno::TestGroup
      title 'ServiceRequest Tests'
      id :pacio_pfe_service_request
      short_description %(
        Verify support for the server capabilities required by the PACIO PFE Service Request Profile.
      )
      description 'TODO: Add description.'
      optional
      run_as_group
    end
  end
end
