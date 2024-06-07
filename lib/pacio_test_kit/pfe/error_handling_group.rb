module PacioTestKit
  module PFE
    class ErrorHandlingGroup < Inferno::TestGroup
      title 'Error Handling Tests'
      id :pacio_pfe_error_handling
      short_description 'Verify PFE server can properly malformed requests.'
      run_as_group
    end
  end
end
