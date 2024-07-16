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
  let(:new_observation) do
    JSON.parse(
      File.read(File.join(__dir__, '..', 'fixtures', 'pfe_single_observation_updated.json'))
    )
  end
  let(:response_headers) do
    { 'Location' => "#{url}/#{resource_type}/456" }
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

  def mock_server(body: nil, status: 200, valid_resource: false)
    request = build_read_request(body:, status:)
    allow_any_instance_of(runnable).to receive(:requests).and_return([request])
    allow_any_instance_of(runnable).to receive(:resource_is_valid?).and_return(valid_resource)
    messages = [{ type: 'error', message: 'resource not conformant' }]
    allow_any_instance_of(runnable).to receive(:messages).and_return(messages) unless valid_resource
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

  before do
    allow_any_instance_of(runnable).to receive(:resource_type).and_return(resource_type)
    allow_any_instance_of(runnable).to receive(:tag).and_return(profile)
  end

  it 'skips when no requests and no read requests were made in previous tests' do
    stub_request(:put, "#{url}/#{resource_type}/#{resource_id}")
      .to_return(status: 200, body: observation.to_json)

    result = run(runnable, id_to_update: resource_id, new_resource: new_observation.to_json, url:)

    expect(result.result).to eq('skip')
    expect(result.result_message).to match(/No #{profile} resource read request was made in previous tests/)
  end

  it 'skips when all read requests were unsuccessful in previous tests' do
    mock_server(status: 401, valid_resource: true)

    stub_request(:put, "#{url}/#{resource_type}/#{resource_id}")
      .to_return(status: 200, body: observation.to_json)

    result = run(runnable, id_to_update: resource_id, new_resource: new_observation.to_json, url:)

    expect(result.result).to eq('skip')
    expect(result.result_message).to match(/All #{profile} resource read requests were unsuccessful/)
  end

  it 'fails if unable to both update a resource that exists and create one on the server' do
    mock_server(body: observation, valid_resource: true)

    stub_request(:put, "#{url}/#{resource_type}/#{resource_id}")
      .to_return(status: 500, body: observation.to_json)

    result = run(runnable, id_to_update: resource_id, new_resource: new_observation.to_json, url:)

    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/Unexpected response status: expected 200/)
  end

  it 'passes if unable to update but instead creates resource not on server' do
    mock_server(body: observation, valid_resource: true)

    body = { resourceType: 'Observation', id: '456', meta: { lastUpdated: 'now' } }.to_json

    stub_request(:put, "#{url}/#{resource_type}/000")
      .to_return(status: 201, body:, headers: response_headers)

    result = run(runnable, id_to_update: '000', new_resource: { resourceType: 'Observation' }.to_json, url:)

    expect(result.result).to eq('pass')
  end

  it 'passes if can update previous read request and returns 200 response and correct metadata' do
    mock_server(body: observation, valid_resource: true)

    stub_request(:put, "#{url}/#{resource_type}/#{resource_id}")
      .to_return(status: 200, body: observation.to_json)

    result = run(runnable, id_to_update: resource_id, new_resource: new_observation.to_json, url:)
    expect(result.result).to eq('pass')
  end
end
