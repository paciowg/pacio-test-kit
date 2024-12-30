RSpec.describe PacioTestKit::MustSupportTest do
  let(:session_data_repo) { Inferno::Repositories::SessionData.new }
  let(:results_repo) { Inferno::Repositories::Results.new }
  let(:test_session) { repo_create(:test_session, test_suite_id: 'pacio_pfe_server') }

  def run(runnable, inputs = {})
    test_run_params = { test_session_id: test_session.id }.merge(runnable.reference_hash)
    test_run = Inferno::Repositories::TestRuns.new.create(test_run_params)
    inputs.each do |name, value|
      session_data_repo.save(
        test_session_id: test_session.id,
        name:,
        value:,
        type: runnable.config.input_type(name)
      )
    end
    Inferno::TestRunner.new(test_session:, test_run:).run(runnable)
  end

  describe 'must support test for regular elements' do
    let(:observation_must_support_test) do
      Inferno::Repositories::Tests.new.find('pfe_v200_ballot_pfe_observation_single_must_support_test')
    end
    let(:observation) do
      FHIR::Observation.new(
        JSON.parse(
          File.read(File.join(__dir__, '..', 'fixtures', 'pfe_single_observation.json'))
        )
      )
    end

    it 'passes when server supports all MS elements' do
      allow_any_instance_of(observation_must_support_test).to receive(:scratch_resources).and_return(
        {
          all: [observation]
        }
      )

      result = run(observation_must_support_test)
      expect(result.result).to eq('skip')
      expect(result.result_message).to include('Observation.extension:device-use')
      expect(result.result_message).to include('Observation.extension:event-location')
      expect(result.result_message).to include('Observation.category:PFEDomain')
      # TODO: value field
    end
  end
end
