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
  let(:results_repo) { Inferno::Repositories::Results.new }
  let(:test_session) { repo_create(:test_session, test_suite_id: 'pacio_pfe_server') }
  let(:url) { 'https://example/r4' }
  let(:resource_type) { 'Observation' }
  let(:resource_id) { '123' }
  let(:patient_id) { 'PFEIG-patientBSJ1' }

  let(:resource_system) { 'http://terminology.hl7.org/CodeSystem/observation-category' }
  let(:resource_code) { 'survey' }

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

  let(:faraday_url) { 'https://example.com/fhirpath' }

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

  it 'passes when search by patient is successful and correct resource is retrieved' do
    mock_server(body: observation)

    stub_request(:post, 'https://example.com/fhirpath/evaluate?path=subject')
      .with(body: observation.to_json)
      .to_return(status: 200, body: { type: 'Reference',
                                      element: { reference: 'Patient/PFEIG-patientBSJ1' } }.to_json,
                 headers: { 'Content-Type' => 'application/json' })

    stub_request(:get, "#{url}/#{resource_type}?patient=#{patient_id}")
      .to_return(status: 200, body: observation_search_response.to_json)

    stub_request(:post, "#{url}/#{resource_type}/_search")
      .with(body: { patient: patient_id })
      .to_return(status: 200, body: observation_search_response.to_json)

    stub_request(:get, "#{url}/#{resource_type}?patient=Patient/#{patient_id}")
      .to_return(status: 200, body: observation_search_response.to_json)

    result = run(runnable, url:)
    expect(result.result).to eq('pass')
  end
end
