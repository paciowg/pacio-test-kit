RSpec.describe PacioTestKit::PatientCategoryDateSearchTest do
  let(:runnable) do
    Class.new(PacioTestKit::PatientCategoryDateSearchTest) do
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
  let(:patient_id) { 'PFEIG-patientBSJ1' }

  let(:resource_system) { 'http://terminology.hl7.org/CodeSystem/observation-category' }
  let(:resource_code) { 'survey' }

  let(:resource_date) { '2020-04-09T18:00:00-05:00' }

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
  let(:fhirpath_patient_response) do
    [{ type: 'Reference', element: { reference: 'Patient/PFEIG-patientBSJ1' } }]
  end
  let(:fhirpath_category_response) do
    [{ type: 'CodeableConcept',
       element: {
         coding: [
           {
             system: 'http://terminology.hl7.org/CodeSystem/observation-category',
             code: 'survey'
           }
         ]
       } }]
  end
  let(:fhirpath_category_coding_response) do
    [{ type: 'coding',
       element: {
         system: 'http://terminology.hl7.org/CodeSystem/observation-category',
         code: 'survey'
       } }]
  end
  let(:fhirpath_category_coding_code_response) do
    [{ type: 'token',
       element: 'survey' }]
  end
  let(:fhirpath_effective_response) do
    [{ type: 'dateTime',
       element: '2020-04-09T18:00:00-05:00' }]
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

  def fhifpath_stub_request(request_path, request_body, response_body)
    stub_request(:post, "#{fhirpath_url}?path=#{request_path}")
      .with(body: request_body.to_json, headers:)
      .to_return(status: 200, body: response_body.to_json)
  end

  def get_search_stub_request(query_params, response_body, status = 200)
    stub_request(:get, "#{url}/#{resource_type}?#{query_params}")
      .to_return(status:, body: response_body)
  end

  it 'fails when search by system is unsuccessful in returning resources' do
    mock_server(body: observation)

    # fhirpath
    fhifpath_stub_request('subject', FHIR.from_contents(observation.to_json), fhirpath_patient_response)
    fhifpath_stub_request('category', FHIR.from_contents(observation.to_json), fhirpath_category_response)
    fhifpath_stub_request('category.coding', FHIR.from_contents(observation.to_json),
                          fhirpath_category_coding_response)
    fhifpath_stub_request('category.coding.code', FHIR.from_contents(observation.to_json),
                          fhirpath_category_coding_code_response)
    fhifpath_stub_request('effective', FHIR.from_contents(observation.to_json), fhirpath_effective_response)

    # search
    get_search_stub_request("patient=Patient/#{patient_id}&category=#{resource_code}&date=#{resource_date}",
                            observation_search_response.to_json)
    get_search_stub_request("patient=#{patient_id}&category=#{resource_code}&date=#{resource_date}",
                            observation_search_response.to_json)
    get_search_stub_request(
      "patient=Patient/#{patient_id}&category=#{resource_system}|#{resource_code}&date=#{resource_date}",
      { resourceType: 'Bundle' }.to_json
    )
    get_search_stub_request("patient=#{patient_id}&category=#{resource_system}|#{resource_code}&date=#{resource_date}",
                            { resourceType: 'Bundle' }.to_json)

    result = run(runnable, url:)
    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/No resources found with system|code search/)
  end

  it 'passes when search by patient + category + date is successful and correct resource is retrieved' do
    mock_server(body: observation)

    # fhirpath
    fhifpath_stub_request('subject', FHIR.from_contents(observation.to_json), fhirpath_patient_response)
    fhifpath_stub_request('category', FHIR.from_contents(observation.to_json), fhirpath_category_response)
    fhifpath_stub_request('category.coding', FHIR.from_contents(observation.to_json),
                          fhirpath_category_coding_response)
    fhifpath_stub_request('category.coding.code', FHIR.from_contents(observation.to_json),
                          fhirpath_category_coding_code_response)
    fhifpath_stub_request('effective', FHIR.from_contents(observation.to_json), fhirpath_effective_response)

    # search
    get_search_stub_request("patient=Patient/#{patient_id}&category=#{resource_code}&date=#{resource_date}",
                            observation_search_response.to_json)
    get_search_stub_request("patient=#{patient_id}&category=#{resource_code}&date=#{resource_date}",
                            observation_search_response.to_json)
    get_search_stub_request(
      "patient=Patient/#{patient_id}&category=#{resource_system}|#{resource_code}&date=#{resource_date}",
      observation_search_response.to_json
    )
    get_search_stub_request("patient=#{patient_id}&category=#{resource_system}|#{resource_code}&date=#{resource_date}",
                            observation_search_response.to_json)

    result = run(runnable, url:)
    expect(result.result).to eq('pass')
  end
end
