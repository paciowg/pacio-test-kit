RSpec.describe PacioTestKit::DocumentReferenceIdentifierSearchTest do
  let(:runnable) do
    Class.new(PacioTestKit::DocumentReferenceIdentifierSearchTest) do
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
  let(:test_session) { repo_create(:test_session, test_suite_id: 'pacio_adi_server') }
  let(:url) { 'https://example/r4' }
  let(:fhirpath_url) { 'https://example.com/fhirpath/evaluate' }
  let(:headers) do
    { 'Content-Type' => 'application/json' }
  end
  let(:profile) { 'ADIDocumentReference' }
  let(:resource_type) { 'DocumentReference' }

  # resource sourced from adi ig: https://hl7.org/fhir/us/pacio-adi/DocumentReference-Example-Smith-Johnson-DocRef-DocumentReference.html

  let(:resource_id) { 'Example-Smith-Johnson-DocRef-DocumentReference' }
  let(:patient_id) { 'Example-Smith-Johnson-Patient1' }
  let(:patient_identifier_value) { '5367-047e62ccf09d4b39a8add708a69b7f38-1' }
  let(:patient_identifier_system) { 'urn:oid:2.16.840.1.113883.3.3208.101.1' }

  let(:document_reference) do
    JSON.parse(
      File.read(File.join(__dir__, '..', 'fixtures', 'adi_document_reference.json'))
    )
  end
  let(:document_reference_search_response) do
    JSON.parse(
      File.read(File.join(__dir__, '..', 'fixtures', 'adi_bundle_document_reference_search_response.json'))
    )
  end

  let(:fhirpath_identifier_response) do
    [
      {
        type: 'Identifier',
        element: {
          system: 'urn:oid:2.16.840.1.113883.3.3208.101.1',
          value: '5367-047e62ccf09d4b39a8add708a69b7f38-1'
        }
      }
    ]
  end
  let(:fhir_document_reference) { FHIR.from_contents(document_reference.to_json) }
  let(:search_query_params_with_system) do
    "identifier=#{patient_identifier_system}|#{patient_identifier_value}"
  end
  let(:search_query_params_without_system) do
    "identifier=#{patient_identifier_value}"
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

  def fhirpath_stub_request(path_param, request_body, response_body)
    stub_request(:post, "#{fhirpath_url}?path=#{path_param}")
      .with(body: request_body.to_json, headers:)
      .to_return(status: 200, body: response_body.to_json)
  end

  def get_search_stub_request(query_params, response_body, status = 200)
    stub_request(:get, "#{url}/#{resource_type}?#{query_params}")
      .to_return(status:, body: response_body)
  end

  it 'passes when search by identifier is successful and correct resource is retrieved' do
    mock_server(body: document_reference)

    fhirpath_stub_request('identifier', fhir_document_reference, fhirpath_identifier_response)
    get_search_stub_request(search_query_params_without_system, document_reference_search_response.to_json)
    get_search_stub_request(search_query_params_with_system, document_reference_search_response.to_json)

    result = run(runnable, url:)
    expect(result.result).to eq('pass')
  end

  it 'fails when search with system does not return expected resources in bundle entry' do
    mock_server(body: document_reference)

    fhirpath_stub_request('identifier', fhir_document_reference, fhirpath_identifier_response)
    get_search_stub_request(search_query_params_without_system, document_reference_search_response.to_json)
    get_search_stub_request(search_query_params_with_system, { resourceType: 'Bundle' }.to_json)

    result = run(runnable, url:)
    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/No resources found with system|code search/)
  end
end
