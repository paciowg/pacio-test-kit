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
  # let(:resource_header) { Inferno::Entities::Header }
  # let(:resource_header_params) {resource_header.id = 'example_id', resource_header.vid = 'example_vid', }

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

  it 'passes when request is successful and resource is created' do
    stub_request(:post, "#{url}/#{resource_type}")
      .to_return(status: 201, body: observation.to_json) # headers: resource_header

    result = run(runnable, resource_inputs: observation.to_json, url:)
    expect(result.result).to eq('pass')
  end

  it 'fails when response status is not 201' do
    stub_request(:post, "#{url}/#{resource_type}")
      .to_return(status: 500, body: {}.to_json, headers: {}) # headers should not be checked if not 201 status

    result = run(runnable, resource_inputs: observation.to_json, url:)
    expect(result.result).to eq('fail')
    expect(entity_result_message.message).to match(/Unexpected response status: expected 201/)
  end

  it 'fails when request is successful but resource created has response body that is not a valid json' do
    stub_request(:post, "#{url}/#{resource_type}")
      .to_return(status: 201, body: '[[') # headers:resource_header

    result = run(runnable, resource_inputs: observation, url:)
    expect(result.result).to eq('fail')
    expect(entity_result_message.message).to match(/not a valid JSON/)
  end

  it 'fails when request is successful but resource created has incorrect resource type' do
    stub_request(:post, "#{url}/#{resource_type}")
      .to_return(status: 201, body: { resourceType: 'Encounter' }.to_json) # headers:resource_header

    result = run(runnable, resource_inputs: observation, url:)
    expect(result.result).to eq('fail')
    expect(entity_result_message.message).to match(/Expected resource type to be: `"Observation"`/)
  end

  it 'fails when response is missing Location header with id, vid attributes' do
    stub_request(:post, "#{url}/#{resource_type}")
      .to_return(status: 500, body: {}.to_json) # headers:resource_header

    result = run(runnable, resource_inputs: observation.to_json, url:)
    expect(result.result).to eq('fail')
    expect(entity_result_message.message).to match(/Expected Location and required headers (id, vid) not found/)
  end

  it 'fails when response Location header does not have both id, vid attributes' do
    stub_request(:post, "#{url}/#{resource_type}")
      .to_return(status: 500, body: {}.to_json) # headers:resource_header

    result = run(runnable, resource_inputs: observation.to_json, url:)
    expect(result.result).to eq('fail')
    expect(entity_result_message.message).to match(/Received Location but required headers (id, vid) not found/)
  end

  it 'fails when response id, meta.versionId, and meta.lastUpdated fields do not update on create' do
    altered_response = observation.to_json
    altered_response['id'] = 'some_other_id_name'
    altered_response['meta'] = { 'versionId' => '23', 'lastUpdated' => '06.30.2024' }

    stub_request(:post, "#{url}/#{resource_type}")
      .to_return(status: 500, body: [altered_response]) # headers:resource_header

    result = run(runnable, resource_inputs: observation.to_json, url:)
    expect(result.result).to eq('fail')
    expect(entity_result_message.message).to match(/Expected resource to have id, meta.versionId, and meta.lastUpdated/)
  end
end
