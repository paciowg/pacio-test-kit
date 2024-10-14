RSpec.describe PacioTestKit::UpdateTest do
  let(:runnable) do
    Class.new(PacioTestKit::UpdateTest) do
      config(
        options: {
          resource_type: 'DocumentReference',
          profile: 'ADIDocumentReference'
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
  let(:test_session) { repo_create(:test_session, test_suite_id: 'pacio_adi_server') }
  let(:url) { 'https://example/r4' }
  let(:resource_type) { 'DocumentReference' }
  # resource sourced from adi ig: https://hl7.org/fhir/us/pacio-adi/DocumentReference-Example-Smith-Johnson-DocRef-DocumentReference.html
  let(:resource_id) { 'Example-Smith-Johnson-DocRef-DocumentReference' }
  let(:profile) { 'ADIDocumentReference' }
  let(:document_reference) do
    JSON.parse(
      File.read(File.join(__dir__, '..', 'fixtures', 'adi_document_reference.json'))
    )
  end
  let(:updated_document_reference) do
    JSON.parse(
      File.read(File.join(__dir__, '..', 'fixtures', 'adi_document_reference_updated.json'))
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

  def entity_result_message
    results_repo.current_results_for_test_session_and_runnables(test_session.id, [runnable])
      .first
      .messages
      .first
  end

  it 'skips when no read request was made in previous tests' do
    result = run(runnable, url:)

    expect(result.result).to eq('skip')
    expect(result.result_message).to match(/No #{profile} resource read request was made in previous tests/)
  end

  it 'skips when read request was unsuccessful in previous tests' do
    mock_server(status: 401)

    result = run(runnable, url:)

    expect(result.result).to eq('skip')
    expect(result.result_message).to match(/resource read requests were unsuccessful/)
  end

  it 'fails if status is not 200' do
    mock_server(body: document_reference)

    stub_request(:put, "#{url}/#{resource_type}/#{resource_id}")
      .to_return(status: 500, body: {}.to_json)

    result = run(runnable, url:)

    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/Unexpected response status: expected 200/)
  end

  it 'fails if resourceType is not the expected one' do
    mock_server(body: document_reference)

    stub_request(:put, "#{url}/#{resource_type}/#{resource_id}")
      .to_return(status: 200, body: { resourceType: 'Encounter' }.to_json)

    result = run(runnable, url:)

    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/Unexpected resource type: expected #{resource_type}/)
  end

  it 'fails when the resource id changes' do
    mock_server(body: document_reference)

    stub_request(:put, "#{url}/#{resource_type}/#{resource_id}")
      .to_return(status: 200, body: { resourceType: 'DocumentReference', id: '456' }.to_json)

    result = run(runnable, url:)

    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/Update must not change the resource ID/)
  end

  it 'fails if the updated status was not persisted' do
    mock_server(body: document_reference)

    stub_request(:put, "#{url}/#{resource_type}/#{resource_id}")
      .to_return(status: 200, body: document_reference.to_json)

    result = run(runnable, url:)

    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/Update failed: Expected status to be updated/)
  end

  it 'fails if response resource meta.lastUpdated is present and is the same as submitted resource meta.lastUpdated' do
    resource_body = { resourceType: 'DocumentReference', id: resource_id, status: 'current',
                      meta: { lastUpdated: 'now' } }.to_json
    mock_server(body: resource_body)

    stub_request(:put, "#{url}/#{resource_type}/#{resource_id}")
      .to_return(status: 200, body: updated_document_reference.to_json)

    result = run(runnable, url:)

    expect(result.result).to eq('fail')
    expect(entity_result_message.message).to match(/Server SHALL ignore `meta.lastUpdated`/)
  end

  it 'fails if response resource meta.versionId is present and is the same as submitted resource meta.versionId' do
    resource_body = { resourceType: 'DocumentReference', id: resource_id, status: 'current',
                      meta: { versionId: 'someVersionId' } }.to_json
    mock_server(body: resource_body)

    stub_request(:put, "#{url}/#{resource_type}/#{resource_id}")
      .to_return(status: 200, body: updated_document_reference.to_json)

    result = run(runnable, url:)

    expect(result.result).to eq('fail')
    expect(entity_result_message.message).to match(/Server SHALL ignore `meta.versionId`/)
  end

  it 'passes if resource is successfully updated' do
    mock_server(body: document_reference)

    stub_request(:put, "#{url}/#{resource_type}/#{resource_id}")
      .to_return(status: 200, body: updated_document_reference.to_json)

    result = run(runnable, url:)
    expect(result.result).to eq('pass')
  end
end
