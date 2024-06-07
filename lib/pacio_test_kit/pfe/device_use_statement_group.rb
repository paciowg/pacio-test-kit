module PacioTestKit
  module PFE
    class DeviceUseStatementGroup < Inferno::TestGroup
      title 'DeviceUseStatement Tests'
      id :pacio_pfe_device_use_statement
      short_description %(
        Verify support for the server capabilities required by the PACIO PFE Use of Device Profile.
      )
      description 'TODO: Add description'
      optional
      run_as_group
    end
  end
end
