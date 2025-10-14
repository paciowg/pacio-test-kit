module PacioTestKit
  module SMP
    class SubmitTest < Inferno::Test
      include PacioTestKit::PacioProfiles

      id :pacio_smp_operation_submit_test

      title 'Server returns valid results for SMP Submit ($smp-submit) operation'
      description %(
        A server MAY support the $smp-submit operation.

        This test will pass if the server response to the $smp-submit operation with output Parameters that conform to
        the SMPParametersOutcome profile.
      )

      input :smp_submit_params,
            type: 'textarea',
            title: 'FHIR Parameters to use for $smp-submit input',
            optional: true,
            description: %(
              Please provide a FHIR Parameters resource that conforms to the SMPOperationSubmit profile. Inferno will
              use it as input parameters for the $smp-submit request. If this is left blank, Inferno will skip the
              $smp-submit test.
            )

      run do
        skip_if smp_submit_params.blank?

        assert_valid_json(smp_submit_params, 'Cannot use input for $smp-submit input Parameters')
        input_params = FHIR.from_contents(smp_submit_params)
        assert_resource_type('Parameters', resource: input_params)
        begin
          assert_valid_resource(resource: input_params, profile_url: PACIO_PROFILES['SMPParametersSubmit'])
        rescue Inferno::Exceptions::AssertionException
          # Allow test to continue even if the input is nonconformant
          warning 'Input for $smp-submit input Parameters was not conformant'
        end

        fhir_operation('$smp-submit', body: input_params)

        assert_response_status(200)
        assert_valid_json(request.response_body)
        assert_resource_type('Parameters')
        assert_valid_resource(profile_url: PACIO_PROFILES['SMPParametersResponse'])
      end
    end
  end
end
