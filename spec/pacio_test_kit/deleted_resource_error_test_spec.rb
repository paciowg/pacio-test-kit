RSpec.describe PacioTestKit::DeletedResourceErrorTest do
  let(:runnable) do
    Class.new(PacioTestKit::DeletedResourceErrorTest) do
      input :url

      fhir_client do
        url :url
      end
    end
  end
  let(:session_data_repo) { Inferno::Repositories::SessionData.new }
  let(:results_repo) { Inferno::Repositories::Results.new }
  let(:test_session) { repo_create(:test_session, test_suite_id: 'pacio_pfe_server') }
  let(:url) { 'https://example/r4' }
  let(:resource_type) { 'Observation' }
  let(:resource_id) { '123' }
  let(:error_outcome) { FHIR::OperationOutcome.new(issue: [{ severity: 'error' }]) }

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

  it 'passes when read request of deleted resource is 410' do
    stub_request(:get, "#{url}/#{resource_type}/#{resource_id}")
      .to_return(status: 410, body: error_outcome.to_json)

    result = run(runnable, resource_ids: '123', resource_types: 'Observation', url:)
    expect(result.result).to eq('pass')
  end

  it 'fails when read request of deleted resource is not 410' do
    stub_request(:get, "#{url}/#{resource_type}/#{resource_id}")
      .to_return(status: 510, body: {}.to_json)

    result = run(runnable, resource_ids: '123', resource_types: 'Observation', url:)
    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/Unexpected response status: expected 410, but received 510/)
  end
end
