RSpec.describe PacioTestKit::UnknownResourceErrorTest do
  let(:runnable) do
    Class.new(PacioTestKit::UnknownResourceErrorTest) do
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

  it 'passes when read request with unknown resource is 404' do
    stub_request(:get, "#{url}/#{resource_type}/#{resource_id}")
      .to_return(status: 404, body: error_outcome.to_json)

    result = run(runnable, resource_ids: '123', resource_types: 'Observation', url:)
    expect(result.result).to eq('pass')
  end

  it 'fails when read request with unknown resource is not 404' do
    stub_request(:get, "#{url}/#{resource_type}/#{resource_id}")
      .to_return(status: 402, body: {}.to_json)

    result = run(runnable, resource_ids: '123', resource_types: 'Observation', url:)
    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/Unexpected response status: expected 404, but received 402/)
  end
end
