require_relative '../pacio_profiles'

module PacioTestKit
  module SMP
    class RetrieveTest < Inferno::Test
      include PacioTestKit::PacioProfiles

      id :pacio_smp_operation_retrieve_test

      title 'Server returns valid results for SMP Retrieve ($smp-query) operation'
      description %(
        A server MAY support the $smp-query operation.

        This test will pass if the server response to the $smp-query operation with output Parameters that conform to
        the SMPParametersResponse profile.
      )

      input :smp_query_params,
            type: 'textarea',
            title: 'FHIR Parameters to use for $smp-query input',
            optional: true,
            description: %(
              Please provide a FHIR Parameters resource that conforms to the SMPParametersQuery profile. Inferno will
              use it as input parameters for the $smp-query request. If this is left blank, Inferno will skip the
              $smp-query test.
            )

      run do
        skip_if smp_query_params.blank?

        assert_valid_json(smp_query_params, 'Cannot use input for $smp-query input Parameters')
        input_params = FHIR.from_contents(smp_query_params)
        assert_resource_type('Parameters', resource: input_params)
        begin
          assert_valid_resource(resource: input_params, profile_url: PACIO_PROFILES['SMPParametersQuery'])
        rescue Inferno::Exceptions::AssertionException
          # Allow test to continue even if the input is nonconformant
          warning 'Input for $smp-query input Parameters was not conformant'
        end

        fhir_operation('$smp-query', body: input_params)

        assert_response_status(200)
        assert_valid_json(request.response_body)
        assert_resource_type('Parameters')
        assert_valid_resource(profile_url: PACIO_PROFILES['SMPParametersResponse'])
      end
    end
  end
end
