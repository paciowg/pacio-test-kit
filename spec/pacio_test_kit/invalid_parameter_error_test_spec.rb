RSpec.describe PacioTestKit::InvalidParameterErrorTest do
  let(:runnable) do
    Class.new(PacioTestKit::InvalidParameterErrorTest) do
      input :url

      fhir_client do
        url :url
      end
    end
  end
  let(:session_data_repo) { Inferno::Repositories::SessionData.new }
  let(:results_repo) { Inferno::Repositories::Results.new }
  let(:suite_id) { 'pacio_pfe_server' }
  let(:test_session) { repo_create(:test_session, test_suite_id: 'pacio_pfe_server') }
  let(:url) { 'https://example/r4' }
  let(:resource_type) { 'Patient' }
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

  it 'passes when a search request with an invalid parameter returns a 400 status' do
    cases = {
      get: { url: "#{url}/#{resource_type}", with: { query: { unknownParam: 'unknown' } } },
      post: { url: "#{url}/#{resource_type}/_search", with: { body: { unknownParam: 'unknown' } } }
    }

    cases.each do |method, cfg|
      stub_request(method, cfg[:url])
        .with(cfg[:with])
        .to_return(status: 400, body: error_outcome.to_json)

      result = run(runnable, url:, search_method: method.to_s)
      expect(result.result).to eq('pass')
    end
  end

  it 'fails when search request with invalid parameter is not 400 status' do
    cases = {
      get: { url: "#{url}/#{resource_type}", with: { query: { unknownParam: 'unknown' } } },
      post: { url: "#{url}/#{resource_type}/_search", with: { body: { unknownParam: 'unknown' } } }
    }

    cases.each do |method, cfg|
      stub_request(method, cfg[:url])
        .with(cfg[:with])
        .to_return(status: 401, body: {}.to_json)
      result = run(runnable, url:, search_method: method.to_s)
      expect(result.result).to eq('fail')
      expect(result.result_message).to match(/Unexpected response status: expected 400, but received 401/)
    end
  end
end
