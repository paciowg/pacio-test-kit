RSpec.describe PacioTestKit::UpdateTest do
  let(:runnable) do
    Class.new(PacioTestKit::UpdateTest) do
      config(
        options: {
          resource_type: 'Observation',
          profile: 'PFESingleObservation'
        }
      )

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
  let(:profile) { 'PFESingleObservation' }
  let(:observation) do
    JSON.parse(
      File.read(File.join(__dir__, '..', 'fixtures', 'pfe_single_observation.json'))
    )
  end
  let(:updated_observation) do
    JSON.parse(
      File.read(File.join(__dir__, '..', 'fixtures', 'pfe_single_observation_updated.json'))
    )
  end

  def build_read_request(body: nil, status: 200, headers: nil)
    repo_create(
      :request,
      direction: 'outgoing',
      url: "#{url}/#{resource_type}/#{resource_id}",
      test_session_id: test_session.id,
      response_body: body.is_a?(Hash) ? body.to_json : body,
      status:,
      headers:,
      verb: 'read'
    )
  end

  def mock_server(body: nil, status: 200)
    request = build_read_request(body:, status:)
    allow_any_instance_of(runnable).to receive(:requests).and_return([request])
  end

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

  it 'skips when no read request was made in previous tests' do
    result = run(runnable, updated_status: 'registered', url:)

    expect(result.result).to eq('skip')
    expect(result.result_message).to match(/No #{profile} resource read request was made in previous tests/)
  end

  it 'skips when read request was unsuccessful in previous tests' do
    mock_server(status: 401)

    result = run(runnable, updated_status: 'registered', url:)

    expect(result.result).to eq('skip')
    expect(result.result_message).to match(/resource read requests were unsuccessful/)
  end

  it 'fails if status is not 200' do
    mock_server(body: observation)

    stub_request(:put, "#{url}/#{resource_type}/#{resource_id}")
      .to_return(status: 500, body: {}.to_json)

    result = run(runnable, updated_status: 'final', url:)

    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/Unexpected response status: expected 200/)
  end

  it 'fails if resource returns 200 but did not successfully update status field' do
    mock_server(body: observation)

    stub_request(:put, "#{url}/#{resource_type}/#{resource_id}")
      .to_return(status: 200, body: observation.to_json)

    result = run(runnable, updated_status: 'final', url:)

    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/resource status was not updated/)
  end

  it 'passes if can update previous read request and returns 200 response' do
    mock_server(body: observation)

    stub_request(:put, "#{url}/#{resource_type}/#{resource_id}")
      .to_return(status: 200, body: updated_observation.to_json)

    result = run(runnable, updated_status: 'registered', url:)
    expect(result.result).to eq('pass')
  end
end
