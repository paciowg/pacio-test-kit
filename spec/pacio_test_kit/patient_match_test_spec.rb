RSpec.describe PacioTestKit::PatientMatchTest do
  let(:runnable) do
    Class.new(PacioTestKit::PatientMatchTest) do
      config(
        options: {
          resource_type: 'Patient',
          profile: 'USCorePatient'
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
  let(:suite_id) { 'pacio_pfe_server' }
  let(:test_session) { repo_create(:test_session, test_suite_id: 'pacio_pfe_server') }
  let(:url) { 'https://example/r4' }
  let(:resource_type) { 'Patient' }
  let(:resource_id) { '123' }
  let(:profile) { 'USCorePatient' }
  let(:observation) do
    FHIR::Patient.new(
      id: resource_id,
      identifier: [
        {
          system: 'http://hospital.smarthealthit.org',
          value: '88483616-e5e4-425b-8d94-a530964754bf'
        },
        {
          system: 'http://hl7.org/fhir/sid/us-medicare',
          value: '10A3D58WH1600'
        }
      ]
    )
  end

  def build_read_request(body: nil, status: 200)
    repo_create(
      :request,
      direction: 'outgoing',
      url: "#{url}/#{resource_type}/#{resource_id}",
      test_session_id: test_session.id,
      response_body: body.is_a?(Hash) ? body.to_json : body,
      status:,
      headers:
    )
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

  before do
    allow_any_instance_of(runnable).to receive(:resource_type).and_return(resource_type)
    allow_any_instance_of(runnable).to receive(:tag).and_return(profile)

    request = build_create_request
    allow_any_instance_of(runnable).to receive(:load_tagged_requests).and_return([request])
  end

  # it 'passes when match returns matched patient' do
  #   stub_request(:get, "#{url}/#{resource_type}/$match")
  #     .to_return(status: 200, body: observation.to_json)

  #   result = run(runnable, resource_ids: resource_id, url:)
  #   expect(result.result).to eq('pass')
  # end

  # it 'fails when response status is not 200' do
  #   stub_request(:get, "#{url}/#{resource_type}/#{resource_id}")
  #     .to_return(status: 500, body: {}.to_json)

  #   result = run(runnable, resource_ids: resource_id, url:)
  #   expect(result.result).to eq('fail')
  #   expect(entity_result_message.message).to match(/Unexpected response status: expected 200/)
  # end

  # it 'fails when the response body is not valid json' do
  #   stub_request(:get, "#{url}/#{resource_type}/#{resource_id}")
  #     .to_return(status: 200, body: '[[')

  #   result = run(runnable, resource_ids: resource_id, url:)
  #   expect(result.result).to eq('fail')
  #   expect(entity_result_message.message).to match(/not a valid JSON/)
  # end

  # it 'fails when the resource type returned is different from the requested one' do
  #   stub_request(:get, "#{url}/#{resource_type}/#{resource_id}")
  #     .to_return(status: 200, body: { resourceType: 'Encounter' }.to_json)

  #   result = run(runnable, resource_ids: resource_id, url:)
  #   expect(result.result).to eq('fail')
  #   expect(entity_result_message.message).to match(/Expected resource type to be: `"Observation"`/)
  # end

  # it 'fails when the returned resource id is not the requested one' do
  #   stub_request(:get, "#{url}/#{resource_type}/abc")
  #     .to_return(status: 200, body: observation.to_json)

  #   result = run(runnable, resource_ids: 'abc', url:)
  #   expect(result.result).to eq('fail')
  #   expect(entity_result_message.message).to match(/Expected resource to have id `"abc"`/)
  # end

  # it 'uses resource id returned by create request if resource_ids is empty' do
  #   request = build_create_request
  #   allow_any_instance_of(runnable).to receive(:load_tagged_requests).and_return([request])

  #   stub_request(:get, "#{url}/#{resource_type}/#{resource_id}")
  #     .to_return(status: 200, body: observation.to_json)

  #   result = run(runnable, resource_ids: '', url:)
  #   expect(result.result).to eq('pass')
  # end

  # it 'uses resource id returned by create request if resource_ids is not specified' do
  #   request = build_create_request
  #   allow_any_instance_of(runnable).to receive(:load_tagged_requests).and_return([request])

  #   stub_request(:get, "#{url}/#{resource_type}/#{resource_id}")
  #     .to_return(status: 200, body: observation.to_json)

  #   result = run(runnable, url:)
  #   expect(result.result).to eq('pass')
  # end
end
