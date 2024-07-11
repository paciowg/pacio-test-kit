RSpec.describe PacioTestKit::CreateTest do
  let(:runnable) do
    Class.new(PacioTestKit::CreateTest) do
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
  let(:observation) do
    JSON.parse(
      File.read(File.join(__dir__, '..', 'fixtures', 'pfe_single_observation.json'))
    )
  end
  let(:observation_json_returned) do
    JSON.parse(
      File.read(File.join(__dir__, '..', 'fixtures', 'pfe_single_observation_response.json'))
    )
  end
  let(:response_headers) do
    { 'Location' => "#{url}/#{resource_type}/456" }
  end
  let(:wrong_format_response_headers) do
    [
      { 'Location' => "#{url}/456/#{resource_type}" },
      { 'Location' => "#{url}/#{resource_type}" },
      { 'Location' => "#{url}/456" },
      { 'Location' => url },
      { 'Location' => '' }
    ]
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

  def entity_result_message
    results_repo.current_results_for_test_session_and_runnables(test_session.id, [runnable])
      .first
      .messages
      .first
  end

  it 'fails when the submitted resource is not a valid json' do
    result = run(runnable, resource_input: '[[', url:)
    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/Invalid JSON./)
  end

  it 'skips when the submitted resource does not include the resourceType field' do
    result = run(runnable, resource_input: { 'id' => '123' }.to_json, url:)
    expect(result.result).to eq('skip')
    expect(result.result_message).to match(/resource input submitted does not have a `resourceType` field/)
  end

  it 'skips when the submitted resource type is not the expected resource type' do
    result = run(runnable, resource_input: { resourceType: 'Encounter' }.to_json, url:)
    expect(result.result).to eq('skip')
    expect(result.result_message).to match(/Unexpected resource type: expected #{resource_type}/)
  end

  it 'fails if the response status is not 201' do
    stub_request(:post, "#{url}/#{resource_type}")
      .to_return(status: 500, body: observation_json_returned.to_json, headers: response_headers)
    result = run(runnable, resource_input: observation.to_json, url:)
    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/Unexpected response status/)
  end

  it 'fails if the response body is not a valid json' do
    stub_request(:post, "#{url}/#{resource_type}")
      .to_return(status: 201, body: '[[', headers: response_headers)
    result = run(runnable, resource_input: observation.to_json, url:)
    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/response must be a valid JSON/)
  end

  it 'fails if the response resource type is not the expected type' do
    stub_request(:post, "#{url}/#{resource_type}")
      .to_return(status: 201, body: { resourceType: 'Encounter' }.to_json, headers: response_headers)

    result = run(runnable, resource_input: observation.to_json, url:)
    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/Unexpected resource type/)
  end

  it 'fails if the response resource id is missing' do
    body = { resourceType: 'Observation', meta: { lastUpdated: 'now' } }.to_json
    stub_request(:post, "#{url}/#{resource_type}").to_return(status: 201, body:, headers: response_headers)

    result = run(runnable, resource_input: observation.to_json, url:)
    expect(result.result).to eq('fail')
    expect(entity_result_message.message).to match(/Server SHALL populate the `id` for the newly created resource/)
  end

  it 'fails if the response resource id is the same as the submitted resource id' do
    body = { resourceType: 'Observation', id: '123', meta: { lastUpdated: 'now' } }.to_json
    stub_request(:post, "#{url}/#{resource_type}").to_return(status: 201, body:, headers: response_headers)

    result = run(runnable, resource_input: observation.to_json, url:)
    expect(result.result).to eq('fail')
    expect(entity_result_message.message).to match(/Server SHALL ignore `id` provided in the request body/)
  end

  it 'fails if response resource meta.lastUpdated is present and is the same as submitted resource meta.lastUpdated' do
    body = { resourceType: 'Observation', id: '567', meta: { lastUpdated: 'now' } }.to_json
    stub_request(:post, "#{url}/#{resource_type}").to_return(status: 201, body:, headers: response_headers)

    resource_input = { resourceType: 'Observation', id: '123', meta: { lastUpdated: 'now' } }.to_json
    result = run(runnable, resource_input:, url:)
    expect(result.result).to eq('fail')
    expect(entity_result_message.message).to match(/SHALL ignore `meta.lastUpdated` provided in the request body/)
  end

  it 'fails if location header is not returned' do
    body = { resourceType: 'Observation', id: '456', meta: { lastUpdated: 'now' } }.to_json
    stub_request(:post, "#{url}/#{resource_type}").to_return(status: 201, body:)

    result = run(runnable, resource_input: observation.to_json, url:)
    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/Server SHALL return a Location header/)
  end

  it 'fails if the location header is not correctly formatted' do
    wrong_format_response_headers.each do |headers|
      body = { resourceType: 'Observation', id: '456', meta: { lastUpdated: 'now' } }.to_json
      stub_request(:post, "#{url}/#{resource_type}").to_return(status: 201, body:, headers:)

      result = run(runnable, resource_input: observation.to_json, url:)
      expect(result.result).to eq('fail')
      expect(result.result_message).to match(/location header is incorrectly formatted/)
    end
  end

  it 'passes when resource is successfully created with the correct metadata and location header is returned' do
    body = { resourceType: 'Observation', id: '456', meta: { lastUpdated: 'now' } }.to_json
    stub_request(:post, "#{url}/#{resource_type}").to_return(status: 201, body:, headers: response_headers)

    result = run(runnable, resource_input: observation.to_json, url:)
    expect(result.result).to eq('pass')
  end
end
