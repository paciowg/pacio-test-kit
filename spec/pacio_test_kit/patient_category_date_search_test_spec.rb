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
  let(:observation_two) do
    JSON.parse(
      File.read(File.join(__dir__, '..', 'fixtures',
                          'pfe_single_observation_2.json'))
    )
  end
  let(:observation_search_response) do
    JSON.parse(
      File.read(File.join(__dir__, '..', 'fixtures', 'pfe_bundle_observation_search_response.json'))
    )
  end
  let(:observation_search_response_wrong_resource_type) do
    JSON.parse(
      File.read(File.join(__dir__, '..', 'fixtures', 'pfe_bundle_observation_search_response_wrong_resource_type.json'))
    )
  end
  let(:observation_search_response_different_search_param_response) do
    JSON.parse(
      File.read(File.join(__dir__, '..', 'fixtures',
                          'pfe_bundle_observation_search_response_different_search_param_response.json'))
    )
  end
  let(:observation_search_response_two) do
    JSON.parse(
      File.read(File.join(__dir__, '..', 'fixtures',
                          'pfe_bundle_observation_search_response_2.json'))
    )
  end
  let(:observation_not_match_response) do
    JSON.parse(
      File.read(File.join(__dir__, '..', 'fixtures',
                          'pfe_bundle_observation_search_response_not_match.json'))
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

  it 'skips when no read or search request was made in previous tests' do
    result = run(runnable, url:)

    expect(result.result).to eq('skip')
    expect(result.result_message).to match(/No #{profile} resource read or search request was made in previous tests/)
  end

  it 'skips when no read or search request was successful in previous tests' do
    mock_server(status: 401)

    result = run(runnable, url:)

    expect(result.result).to eq('skip')
    expect(result.result_message).to match(/All #{profile} resource read or search requests failed/)
  end

  it 'fails if status for search by get reference by type is not 200' do
    mock_server(body: observation)

    stub_request(:post, 'https://example.com/fhirpath/evaluate?path=subject')
      .with(body: FHIR.from_contents(observation.to_json).to_json, headers: { 'Content-Type' => 'application/json' })
      .to_return(status: 200, body: [{ type: 'Reference',
                                       element: { reference: 'Patient/PFEIG-patientBSJ1' } }].to_json,
                 headers: { 'Content-Type' => 'application/json' })

    stub_request(:post, 'https://example.com/fhirpath/evaluate?path=category')
      .with(body: FHIR.from_contents(observation.to_json).to_json, headers: { 'Content-Type' => 'application/json' })
      .to_return(status: 200, body: [{ type: 'CodeableConcept',
                                       element: 'survey' }].to_json,
                 headers: { 'Content-Type' => 'application/json' })

    stub_request(:post, 'https://example.com/fhirpath/evaluate?path=effective')
      .with(body: FHIR.from_contents(observation.to_json).to_json, headers: { 'Content-Type' => 'application/json' })
      .to_return(status: 200, body: [{ type: 'Coding',
                                       element: '2020-04-09T18:00:00-05:00' }].to_json,
                 headers: { 'Content-Type' => 'application/json' })

    stub_request(:get, "#{url}/#{resource_type}?patient=Patient/#{patient_id}&category=#{resource_code}&date=#{resource_date}")
      .to_return(status: 500, body: {}.to_json)

    result = run(runnable, url:)
    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/Unexpected response status: expected 200, but received 500/)
  end

  it 'fails if status for search by get is not 200' do
    mock_server(body: observation)

    stub_request(:post, 'https://example.com/fhirpath/evaluate?path=subject')
      .with(body: FHIR.from_contents(observation.to_json).to_json, headers: { 'Content-Type' => 'application/json' })
      .to_return(status: 200, body: [{ type: 'Reference',
                                       element: { reference: 'Patient/PFEIG-patientBSJ1' } }].to_json,
                 headers: { 'Content-Type' => 'application/json' })
    stub_request(:post, 'https://example.com/fhirpath/evaluate?path=category')
      .with(body: FHIR.from_contents(observation.to_json).to_json, headers: { 'Content-Type' => 'application/json' })
      .to_return(status: 200, body: [{ type: 'CodeableConcept',
                                       element: 'survey' }].to_json,
                 headers: { 'Content-Type' => 'application/json' })
    stub_request(:post, 'https://example.com/fhirpath/evaluate?path=effective')
      .with(body: FHIR.from_contents(observation.to_json).to_json, headers: { 'Content-Type' => 'application/json' })
      .to_return(status: 200, body: [{ type: 'Coding',
                                       element: '2020-04-09T18:00:00-05:00' }].to_json,
                 headers: { 'Content-Type' => 'application/json' })

    stub_request(:get, "#{url}/#{resource_type}?patient=Patient/#{patient_id}&category=#{resource_code}&date=#{resource_date}")
      .to_return(status: 500, body: {}.to_json)

    stub_request(:get, "#{url}/#{resource_type}?patient=#{patient_id}&category=#{resource_code}&date=#{resource_date}")
      .to_return(status: 500, body: {}.to_json)

    result = run(runnable, url:)
    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/Unexpected response status: expected 200, but received 500/)
  end

  # TODO: not working
  # it 'fails status for search by post is not 200' do
  #   mock_server(body: observation)

  #   stub_request(:post, 'https://example.com/fhirpath/evaluate?path=subject')
  #     .with(body: FHIR.from_contents(observation.to_json).to_json, headers: { 'Content-Type' => 'application/json' })
  #     .to_return(status: 200, body: [{ type: 'Reference',
  #                                      element: { reference: 'Patient/PFEIG-patientBSJ1' } }].to_json,
  #                headers: { 'Content-Type' => 'application/json' })
  #   stub_request(:post, 'https://example.com/fhirpath/evaluate?path=category')
  #     .with(body: FHIR.from_contents(observation.to_json).to_json, headers: { 'Content-Type' => 'application/json' })
  #     .to_return(status: 200, body: [{ type: 'CodeableConcept',
  #                                      element: {
  #                                        coding: [
  #                                          {
  #                                            system: 'http://terminology.hl7.org/CodeSystem/observation-category',
  #                                            code: 'survey'
  #                                          }
  #                                        ]
  #                                      } }].to_json,
  #                headers: { 'Content-Type' => 'application/json' })
  #   stub_request(:post, 'https://example.com/fhirpath/evaluate?path=category.coding.code')
  #     .with(body: FHIR.from_contents(observation.to_json).to_json, headers: { 'Content-Type' => 'application/json' })
  #     .to_return(status: 200, body: [{ type: 'CodeableConcept',
  #                                      element: {
  #                                        coding: [
  #                                          {
  #                                            system: 'http://terminology.hl7.org/CodeSystem/observation-category',
  #                                            code: 'survey'
  #                                          }
  #                                        ]
  #                                      } }].to_json,
  #                headers: { 'Content-Type' => 'application/json' })
  #   stub_request(:post, 'https://example.com/fhirpath/evaluate?path=effective')
  #     .with(body: FHIR.from_contents(observation.to_json).to_json, headers: { 'Content-Type' => 'application/json' })
  #     .to_return(status: 200, body: [{ type: 'Coding',
  #                                      element: '2020-04-09T18:00:00-05:00' }].to_json,
  #                headers: { 'Content-Type' => 'application/json' })

  #   stub_request(:get, "#{url}/#{resource_type}?patient=Patient/#{patient_id}&category=#{resource_code}&date=#{resource_date}")
  #     .to_return(status: 200, body: observation_search_response.to_json)

  #   stub_request(:post, "#{url}/#{resource_type}/_search")
  #     .with(body: { patient: "Patient/#{patient_id}", category: resource_code,
  #                   date: resource_date })
  #     .to_return(status: 500, body: {}.to_json)

  #   result = run(runnable, url:)
  #   expect(result.result).to eq('fail')
  #   expect(result.result_message).to match(/Unexpected response status: expected 200, but received 500/)
  # end
end
