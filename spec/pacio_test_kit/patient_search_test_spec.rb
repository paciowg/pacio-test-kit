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

    stub_request(:get, "#{url}/#{resource_type}?patient=Patient/#{patient_id}")
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

    stub_request(:get, "#{url}/#{resource_type}?patient=Patient/#{patient_id}")
      .to_return(status: 200, body: observation_search_response.to_json)

    stub_request(:post, "#{url}/#{resource_type}/_search")
      .with(body: { patient: "Patient/#{patient_id}" })
      .to_return(status: 200, body: observation_search_response.to_json)

    stub_request(:get, "#{url}/#{resource_type}?patient=#{patient_id}")
      .to_return(status: 500, body: {}.to_json)

    result = run(runnable, url:)
    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/Unexpected response status: expected 200, but received 500/)
  end

  it 'fails status for search by post is not 200' do
    mock_server(body: observation)

    stub_request(:post, 'https://example.com/fhirpath/evaluate?path=subject')
      .with(body: FHIR.from_contents(observation.to_json).to_json, headers: { 'Content-Type' => 'application/json' })
      .to_return(status: 200, body: [{ type: 'Reference',
                                       element: { reference: 'Patient/PFEIG-patientBSJ1' } }].to_json,
                 headers: { 'Content-Type' => 'application/json' })

    stub_request(:get, "#{url}/#{resource_type}?patient=Patient/#{patient_id}")
      .to_return(status: 200, body: observation_search_response.to_json)

    stub_request(:post, "#{url}/#{resource_type}/_search")
      .with(body: { patient: "Patient/#{patient_id}" })
      .to_return(status: 500, body: {}.to_json)

    result = run(runnable, url:)
    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/Unexpected response status: expected 200, but received 500/)
  end

  it 'fails if return type of search by get is not type bundle' do
    mock_server(body: observation)

    stub_request(:post, 'https://example.com/fhirpath/evaluate?path=subject')
      .with(body: FHIR.from_contents(observation.to_json).to_json, headers: { 'Content-Type' => 'application/json' })
      .to_return(status: 200, body: [{ type: 'Reference',
                                       element: { reference: 'Patient/PFEIG-patientBSJ1' } }].to_json,
                 headers: { 'Content-Type' => 'application/json' })

    stub_request(:get, "#{url}/#{resource_type}?patient=Patient/#{patient_id}")
      .to_return(status: 200, body: observation_search_response.to_json)

    stub_request(:post, "#{url}/#{resource_type}/_search")
      .with(body: { patient: "Patient/#{patient_id}" })
      .to_return(status: 200, body: observation_search_response.to_json)

    stub_request(:get, "#{url}/#{resource_type}?patient=#{patient_id}")
      .to_return(status: 200, body: { resourceType: 'Encounter' }.to_json)

    result = run(runnable, url:)
    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/Unexpected resource type: expected Bundle/)
  end

  it 'fails if return type of search by post is not type bundle' do
    mock_server(body: observation)

    stub_request(:post, 'https://example.com/fhirpath/evaluate?path=subject')
      .with(body: FHIR.from_contents(observation.to_json).to_json, headers: { 'Content-Type' => 'application/json' })
      .to_return(status: 200, body: [{ type: 'Reference',
                                       element: { reference: 'Patient/PFEIG-patientBSJ1' } }].to_json,
                 headers: { 'Content-Type' => 'application/json' })

    stub_request(:get, "#{url}/#{resource_type}?patient=Patient/#{patient_id}")
      .to_return(status: 200, body: observation_search_response.to_json)

    stub_request(:post, "#{url}/#{resource_type}/_search")
      .with(body: { patient: "Patient/#{patient_id}" })
      .to_return(status: 200, body: { resourceType: 'Encounter' }.to_json)

    stub_request(:get, "#{url}/#{resource_type}?patient=#{patient_id}")
      .to_return(status: 200, body: observation_search_response.to_json)

    result = run(runnable, url:)
    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/Unexpected resource type: expected Bundle/)
  end

  it 'fails if return type of search by get reference with type is not type bundle' do
    mock_server(body: observation)

    stub_request(:post, 'https://example.com/fhirpath/evaluate?path=subject')
      .with(body: FHIR.from_contents(observation.to_json).to_json, headers: { 'Content-Type' => 'application/json' })
      .to_return(status: 200, body: [{ type: 'Reference',
                                       element: { reference: 'Patient/PFEIG-patientBSJ1' } }].to_json,
                 headers: { 'Content-Type' => 'application/json' })

    stub_request(:get, "#{url}/#{resource_type}?patient=Patient/#{patient_id}")
      .to_return(status: 200, body: { resourceType: 'Encounter' }.to_json)

    stub_request(:post, "#{url}/#{resource_type}/_search")
      .with(body: { patient: "Patient/#{patient_id}" })
      .to_return(status: 200, body: observation_search_response.to_json)

    stub_request(:get, "#{url}/#{resource_type}?patient=#{patient_id}")
      .to_return(status: 200, body: observation_search_response.to_json)

    result = run(runnable, url:)
    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/Unexpected resource type: expected Bundle/)
  end

  it 'fails if return type of search by get and logs error if not valid json' do
    mock_server(body: observation)

    stub_request(:post, 'https://example.com/fhirpath/evaluate?path=subject')
      .with(body: FHIR.from_contents(observation.to_json).to_json, headers: { 'Content-Type' => 'application/json' })
      .to_return(status: 200, body: [{ type: 'Reference',
                                       element: { reference: 'Patient/PFEIG-patientBSJ1' } }].to_json,
                 headers: { 'Content-Type' => 'application/json' })

    stub_request(:get, "#{url}/#{resource_type}?patient=Patient/#{patient_id}")
      .to_return(status: 200, body: '[[')

    stub_request(:post, "#{url}/#{resource_type}/_search")
      .with(body: { patient: "Patient/#{patient_id}" })
      .to_return(status: 200, body: observation_search_response.to_json)

    stub_request(:get, "#{url}/#{resource_type}?patient=#{patient_id}")
      .to_return(status: 200, body: '[[')

    result = run(runnable, url:)
    expect(result.result).to eq('error')
    expect(result.result_message).to match(/Error: unexpected token at/)
    # TODO: how to check logger error msg
  end

  it 'fails if return type of search by post is not valid json' do
    mock_server(body: observation)

    stub_request(:post, 'https://example.com/fhirpath/evaluate?path=subject')
      .with(body: FHIR.from_contents(observation.to_json).to_json, headers: { 'Content-Type' => 'application/json' })
      .to_return(status: 200, body: [{ type: 'Reference',
                                       element: { reference: 'Patient/PFEIG-patientBSJ1' } }].to_json,
                 headers: { 'Content-Type' => 'application/json' })

    stub_request(:get, "#{url}/#{resource_type}?patient=#{patient_id}")
      .to_return(status: 200, body: observation_search_response.to_json)

    stub_request(:post, "#{url}/#{resource_type}/_search")
      .with(body: { patient: "Patient/#{patient_id}" })
      .to_return(status: 200, body: '[[')

    stub_request(:get, "#{url}/#{resource_type}?patient=Patient/#{patient_id}")
      .to_return(status: 200, body: observation_search_response.to_json)

    result = run(runnable, url:)
    expect(result.result).to eq('error')
    expect(result.result_message).to match(/Error: unexpected token at/)
    # TODO: how to check logger error msg
  end

  it 'fails if the resource returned is not the expected resourceType' do
    mock_server(body: observation)

    stub_request(:post, 'https://example.com/fhirpath/evaluate?path=subject')
      .with(body: FHIR.from_contents(observation.to_json).to_json, headers: { 'Content-Type' => 'application/json' })
      .to_return(status: 200, body: [{ type: 'Reference',
                                       element: { reference: 'Patient/PFEIG-patientBSJ1' } }].to_json,
                 headers: { 'Content-Type' => 'application/json' })

    stub_request(:get, "#{url}/#{resource_type}?patient=#{patient_id}")
      .to_return(status: 200, body: observation_search_response_wrong_resource_type.to_json)

    stub_request(:post, "#{url}/#{resource_type}/_search")
      .with(body: { patient: "Patient/#{patient_id}" })
      .to_return(status: 200, body: observation_search_response_wrong_resource_type.to_json)

    stub_request(:get, "#{url}/#{resource_type}?patient=Patient/#{patient_id}")
      .to_return(status: 200, body: observation_search_response_wrong_resource_type.to_json)

    result = run(runnable, url:)
    expect(result.result).to eq('skip')
    expect(result.result_message).to match(/No #{resource_type} resources appear to be available. Please provide id/)
  end

  it 'logs if the resource returned a bundle of unexpected resourceTypes' do
    mock_server(body: observation)

    stub_request(:post, 'https://example.com/fhirpath/evaluate?path=subject')
      .with(body: FHIR.from_contents(observation.to_json).to_json, headers: { 'Content-Type' => 'application/json' })
      .to_return(status: 200, body: [{ type: 'Reference',
                                       element: { reference: 'Patient/PFEIG-patientBSJ1' } }].to_json,
                 headers: { 'Content-Type' => 'application/json' })

    stub_request(:get, "#{url}/#{resource_type}?patient=#{patient_id}")
      .to_return(status: 200, body: observation_search_response_two.to_json)

    stub_request(:post, "#{url}/#{resource_type}/_search")
      .with(body: { patient: "Patient/#{patient_id}" })
      .to_return(status: 200, body: observation_search_response_two.to_json)

    stub_request(:get, "#{url}/#{resource_type}?patient=Patient/#{patient_id}")
      .to_return(status: 200, body: observation_search_response_two.to_json)

    result = run(runnable, url:)
    expect(result.result).to eq('pass')
    expect(entity_result_message.message).to match(/This is unusual but allowed/)
  end

  # TODO: NOT WORKING
  # it 'fails when resource retrieved does not match the search parameters' do
  #   mock_server(body: observation)

  #   stub_request(:post, 'https://example.com/fhirpath/evaluate?path=subject')
  #     .with(body: FHIR.from_contents(observation.to_json).to_json, headers: { 'Content-Type' => 'application/json' })
  #     .to_return(status: 200, body: [{ type: 'Reference',
  #                                      element: { reference: "Patient/#{patient_id}" } }].to_json,
  #                headers: { 'Content-Type' => 'application/json' })

  #   stub_request(:post, 'https://example.com/fhirpath/evaluate?path=subject')
  #     .with(body: FHIR.from_contents(observation_not_match_response.to_json).to_json, headers: { 'Content-Type' => 'application/json' })
  #     .to_return(status: 200, body: [{ type: 'Reference',
  #                                      element: { reference: 'Patient/PFEIG-wrong-id' } }].to_json,
  #                headers: { 'Content-Type' => 'application/json' })

  #   stub_request(:get, "#{url}/#{resource_type}?patient=#{patient_id}")
  #     .to_return(status: 200, body: observation_search_response.to_json)

  #   stub_request(:post, "#{url}/#{resource_type}/_search")
  #     .with(body: { patient: "Patient/#{patient_id}" })
  #     .to_return(status: 200, body: observation_search_response.to_json)

  #   stub_request(:get, "#{url}/#{resource_type}?patient=Patient/#{patient_id}")
  #     .to_return(status: 200, body: observation_not_match_response.to_json)

  #   result = run(runnable, url:)
  #   expect(result.result).to eq('fail')
  #   expect(result.result_message).to match(/did not match the search parameters/)
  # end

  it 'fails if unable to retrieve search parameters' do
    mock_server(body: observation)

    stub_request(:post, 'https://example.com/fhirpath/evaluate?path=subject')
      .with(body: FHIR.from_contents(observation.to_json).to_json, headers: { 'Content-Type' => 'application/json' })
      .to_return(status: 200, body: [{ type: 'Reference',
                                       element: { reference: '' } }].to_json,
                 headers: { 'Content-Type' => 'application/json' })

    result = run(runnable, url:)
    expect(result.result).to eq('skip')
    expect(result.result_message).to match(/Could not find values for all search params patient/)
  end

  it 'fails if resources returned from post and get search methods were not the same' do
    mock_server(body: observation)

    stub_request(:post, 'https://example.com/fhirpath/evaluate?path=subject')
      .with(body: FHIR.from_contents(observation.to_json).to_json, headers: { 'Content-Type' => 'application/json' })
      .to_return(status: 200, body: [{ type: 'Reference',
                                       element: { reference: 'Patient/PFEIG-patientBSJ1' } }].to_json,
                 headers: { 'Content-Type' => 'application/json' })
    stub_request(:post, 'https://example.com/fhirpath/evaluate?path=subject')
      .with(body: FHIR.from_contents(observation_two.to_json).to_json, headers: { 'Content-Type' => 'application/json' })
      .to_return(status: 200, body: [{ type: 'Reference',
                                       element: { reference: 'Patient/wrong-patient-id' } }].to_json,
                 headers: { 'Content-Type' => 'application/json' })

    stub_request(:get, "#{url}/#{resource_type}?patient=#{patient_id}")
      .to_return(status: 200, body: observation_search_response_two.to_json)

    stub_request(:post, "#{url}/#{resource_type}/_search")
      .with(body: { patient: "Patient/#{patient_id}" })
      .to_return(status: 200, body: observation_search_response.to_json)

    stub_request(:get, "#{url}/#{resource_type}?patient=Patient/#{patient_id}")
      .to_return(status: 200, body: observation_search_response_two.to_json)

    result = run(runnable, url:)
    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/Expected POST search to return the same results as GET, but found/)
  end

  it 'fails if resources returned from variations of get search methods were not the same' do
    mock_server(body: observation)

    stub_request(:post, 'https://example.com/fhirpath/evaluate?path=subject')
      .with(body: FHIR.from_contents(observation.to_json).to_json, headers: { 'Content-Type' => 'application/json' })
      .to_return(status: 200, body: [{ type: 'Reference',
                                       element: { reference: 'Patient/PFEIG-patientBSJ1' } }].to_json,
                 headers: { 'Content-Type' => 'application/json' })
    stub_request(:post, 'https://example.com/fhirpath/evaluate?path=subject')
      .with(body: FHIR.from_contents(observation_two.to_json).to_json, headers: { 'Content-Type' => 'application/json' })
      .to_return(status: 200, body: [{ type: 'Reference',
                                       element: { reference: 'Patient/wrong-patient-id' } }].to_json,
                 headers: { 'Content-Type' => 'application/json' })

    stub_request(:get, "#{url}/#{resource_type}?patient=#{patient_id}")
      .to_return(status: 200, body: observation_search_response_two.to_json)

    stub_request(:post, "#{url}/#{resource_type}/_search")
      .with(body: { patient: "Patient/#{patient_id}" })
      .to_return(status: 200, body: observation_search_response.to_json)

    stub_request(:get, "#{url}/#{resource_type}?patient=Patient/#{patient_id}")
      .to_return(status: 200, body: observation_search_response.to_json)

    result = run(runnable, url:)
    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/to return the same results as searching by/)
  end

  it 'passes when search by patient is successful and correct resource is retrieved' do
    mock_server(body: observation)

    stub_request(:post, 'https://example.com/fhirpath/evaluate?path=subject')
      .with(body: FHIR.from_contents(observation.to_json).to_json, headers: { 'Content-Type' => 'application/json' })
      .to_return(status: 200, body: [{ type: 'Reference',
                                       element: { reference: 'Patient/PFEIG-patientBSJ1' } }].to_json,
                 headers: { 'Content-Type' => 'application/json' })

    stub_request(:get, "#{url}/#{resource_type}?patient=#{patient_id}")
      .to_return(status: 200, body: observation_search_response.to_json)

    stub_request(:post, "#{url}/#{resource_type}/_search")
      .with(body: { patient: "Patient/#{patient_id}" })
      .to_return(status: 200, body: observation_search_response.to_json)

    stub_request(:get, "#{url}/#{resource_type}?patient=Patient/#{patient_id}")
      .to_return(status: 200, body: observation_search_response.to_json)

    result = run(runnable, url:)
    expect(result.result).to eq('pass')
  end
end
