RSpec.describe PacioTestKit::PatientSearchTest do
  let(:runnable) do
    Class.new(PacioTestKit::PatientSearchTest) do
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
  let(:test_session) { repo_create(:test_session, test_suite_id: 'pacio_pfe_server') }
  let(:url) { 'https://example/r4' }
  let(:resource_type) { 'Observation' }
  let(:resource_id) { '123' }
  let(:patient_id) { 'PFEIG-patientBSJ1' }

  let(:profile) { 'PFESingleObservation' }

  let(:observation) do
    JSON.parse(
      File.read(File.join(__dir__, '..', 'fixtures', 'pfe_single_observation.json'))
    )
  end

  let(:observation_search_response) do
    JSON.parse(
      File.read(File.join(__dir__, '..', 'fixtures', 'pfe_bundle_observation_search_response.json'))
    )
  end

  let(:fhirpath_url) { 'https://example.com/fhirpath/evaluate' }
  let(:headers) do
    { 'Content-Type' => 'application/json' }
  end
  let(:fhirpath_response) do
    [{ type: 'Reference', element: { reference: 'Patient/PFEIG-patientBSJ1' } }]
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

  def fhirpath_stub_request(request_body, response_body)
    stub_request(:post, "#{fhirpath_url}?path=subject")
      .with(body: request_body.to_json, headers:)
      .to_return(status: 200, body: response_body.to_json)
  end

  def get_search_stub_request(query_params, response_body, status = 200)
    stub_request(:get, "#{url}/#{resource_type}?#{query_params}")
      .to_return(status:, body: response_body)
  end

  def post_search_stub_request(request_body, response_body, status = 200)
    stub_request(:post, "#{url}/#{resource_type}/_search")
      .with(body: request_body)
      .to_return(status:, body: response_body)
  end

  it 'passes when search by patient is successful and correct resource is retrieved' do
    mock_server(body: observation)
    fhirpath_stub_request(FHIR.from_contents(observation.to_json), fhirpath_response)
    get_search_stub_request("patient=#{patient_id}", observation_search_response.to_json)
    post_search_stub_request({ patient: "Patient/#{patient_id}" }, observation_search_response.to_json)
    get_search_stub_request("patient=Patient/#{patient_id}", observation_search_response.to_json)

    result = run(runnable, url:)
    expect(result.result).to eq('pass')
  end

  it 'skips when no read request was made in previous tests' do
    result = run(runnable, url:)

    expect(result.result).to eq('skip')
    expect(result.result_message).to match(/No #{profile} resource read request was made in previous tests/)
  end

  it 'skips when no read request was successful in previous tests' do
    mock_server(status: 401)

    result = run(runnable, url:)

    expect(result.result).to eq('skip')
    expect(result.result_message).to match(/All #{profile} resource read requests failed/)
  end

  it 'skips if unable to retrieve search parameters values' do
    mock_server(body: observation)
    fhirpath_response.first[:element][:reference] = ''
    fhirpath_stub_request(FHIR.from_contents(observation.to_json), fhirpath_response)

    result = run(runnable, url:)
    expect(result.result).to eq('skip')
    expect(result.result_message).to match(/Could not find values for all search params/)
  end

  it 'fails if response status for `GET` search is not 200' do
    mock_server(body: observation)
    fhirpath_stub_request(FHIR.from_contents(observation.to_json), fhirpath_response)
    get_search_stub_request("patient=Patient/#{patient_id}", {}.to_json, 500)

    result = run(runnable, url:)
    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/Unexpected response status: expected 200, but received 500/)
  end

  it 'fails if response for `GET` search is not a valid json' do
    mock_server(body: observation)
    fhirpath_stub_request(FHIR.from_contents(observation.to_json), fhirpath_response)
    get_search_stub_request("patient=Patient/#{patient_id}", '[[')

    result = run(runnable, url:)
    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/Invalid JSON/)
  end

  it 'fails if the response resource type of `GET` search is not a bundle' do
    mock_server(body: observation)
    fhirpath_stub_request(FHIR.from_contents(observation.to_json), fhirpath_response)
    get_search_stub_request("patient=Patient/#{patient_id}", { resourceType: 'Encounter' }.to_json)

    result = run(runnable, url:)
    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/Unexpected resource type: expected Bundle/)
  end

  it 'skips if the response bundle entry does not contain at least one expected resource type' do
    mock_server(body: observation)
    fhirpath_stub_request(FHIR.from_contents(observation.to_json), fhirpath_response)
    get_search_stub_request("patient=Patient/#{patient_id}", { resourceType: 'Bundle', entry: [] }.to_json)

    result = run(runnable, url:)
    expect(result.result).to eq('skip')
    expect(result.result_message).to match(/No #{resource_type} resources appear to be available/)
  end

  it 'fails if none of the resource retrieved matches the search criteria' do
    mock_server(body: observation)
    fhirpath_stub_request(FHIR.from_contents(observation.to_json), fhirpath_response)
    get_search_stub_request("patient=Patient/#{patient_id}", observation_search_response.to_json)

    allow_any_instance_of(runnable).to receive(:resource_matches_param?).and_return(false)
    result = run(runnable, url:)
    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/did not match the search parameters/)
  end

  it 'fails if response status for `POST` search is not 200' do
    mock_server(body: observation)
    fhirpath_stub_request(FHIR.from_contents(observation.to_json), fhirpath_response)
    get_search_stub_request("patient=Patient/#{patient_id}", observation_search_response.to_json)
    post_search_stub_request({ patient: "Patient/#{patient_id}" }, {}.to_json, 500)

    result = run(runnable, url:)
    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/Unexpected response status: expected 200, but received 500/)
  end

  it 'fails if response for `POST` search is not a valid json' do
    mock_server(body: observation)
    fhirpath_stub_request(FHIR.from_contents(observation.to_json), fhirpath_response)
    get_search_stub_request("patient=Patient/#{patient_id}", observation_search_response.to_json)
    post_search_stub_request({ patient: "Patient/#{patient_id}" }, '[[')

    result = run(runnable, url:)
    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/Invalid JSON/)
  end

  it 'fails if the response resource type of `POST` search is not a bundle' do
    mock_server(body: observation)
    fhirpath_stub_request(FHIR.from_contents(observation.to_json), fhirpath_response)
    get_search_stub_request("patient=Patient/#{patient_id}", observation_search_response.to_json)
    post_search_stub_request({ patient: "Patient/#{patient_id}" }, { resourceType: 'Encounter' }.to_json)

    result = run(runnable, url:)
    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/Unexpected resource type: expected Bundle/)
  end

  it 'fails if the number of resources returned from post and get search is not the same' do
    mock_server(body: observation)
    fhirpath_stub_request(FHIR.from_contents(observation.to_json), fhirpath_response)
    get_search_stub_request("patient=Patient/#{patient_id}", observation_search_response.to_json)
    post_search_stub_request({ patient: "Patient/#{patient_id}" }, { resourceType: 'Bundle', entry: [] }.to_json)

    result = run(runnable, url:)
    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/Expected POST search to return the same results as GET, but found/)
  end

  it 'fails if number of expected resources from the patient variant searches is not the same' do
    mock_server(body: observation)
    fhirpath_stub_request(FHIR.from_contents(observation.to_json), fhirpath_response)
    get_search_stub_request("patient=Patient/#{patient_id}", observation_search_response.to_json)
    post_search_stub_request({ patient: "Patient/#{patient_id}" }, observation_search_response.to_json)
    get_search_stub_request("patient=#{patient_id}", { resourceType: 'Bundle', entry: [] }.to_json)

    result = run(runnable, url:)
    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/to return the same results as searching by/)
  end
end
