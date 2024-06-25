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
    stub_request(:post, "#{url}/#{resource_type}/#{observation}")
      .to_return(status: 200, body: observation)

    result = run(runnable, resource_list: observation, url:)
    expect(result.result).to eq('pass')
  end

  it 'fails when response status is not 200' do
    stub_request(:post, "#{url}/#{resource_type}/#{observation}")
      .to_return(status: 500, body: {}.to_json)

    result = run(runnable, resource_list: observation, url:)
    expect(result.result).to eq('fail')
    expect(entity_result_message.message).to match(/Unexpected response status: expected 200/)
  end

  # 1. tests to validate the response of the create request

  it 'fails when request is successful but resource created has response body that is not a valid json' do
    stub_request(:post, "#{url}/#{resource_type}/#{observation}")
      .to_return(status: 200, body: '[[')

    result = run(runnable, resource_list: observation, url:)
    expect(result.result).to eq('fail')
    expect(entity_result_message.message).to match(/not a valid JSON/)
  end

  it 'fails when request is successful but resource created has incorrect resource type' do
    stub_request(:post, "#{url}/#{resource_type}/#{observation}")
      .to_return(status: 200, body: { resourceType: 'Encounter' }.to_json)

    result = run(runnable, resource_list: observation, url:)
    expect(result.result).to eq('fail')
    expect(entity_result_message.message).to match(/Expected resource type to be: `"Observation"`/)
  end

  it 'fails when request is successful but resource created has an empty created_at timestamp' do
    stub_request(:post, "#{url}/#{resource_type}/#{observation}")
      .to_return(status: 200, body: observation)

    result = run(runnable, resource_list: observation, url:)
    expect(result.result).to eq('fail')
    expect(entity_result_message.message).to match(/Expected resource created to have creation time: `"Observation"`/)
  end

  it 'fails when request is successful but resource created has a different json than response' do
    stub_request(:post, "#{url}/#{resource_type}/#{observation}")
      .to_return(status: 200, body: observation)

    result = run(runnable, resource_list: {}, url:)
    expect(result.result).to eq('fail')
    expect(entity_result_message.message).to match(/Expected resource created to have request body`/)
  end

  # 2. tests to read the resource just created

  it 'fails when reading a resource just created that does not have a valid json' do
    # create
    stub_request(:post, "#{url}/#{resource_type}/#{observation}")
      .to_return(status: 200, body: observation)
    create_result = run(runnable, resource_list: observation, url:)
    expect(create_result.result).to eq('pass')

    # read resource created
    stub_request(:get, "#{url}/#{resource_type}/#{create_result.response}")
      .to_return(status: 200, body: '[[')
    result = run(runnable, resource_ids: resource_id, url:)
    expect(result.result).to eq('fail')
    expect(entity_result_message.message).to match(/not a valid JSON/)
  end

  it 'fails when reading a resource just created that has a different type than the requested one' do
    # create
    stub_request(:post, "#{url}/#{resource_type}/#{observation}")
      .to_return(status: 200, body: observation)
    create_result = run(runnable, resource_list: observation, url:)
    expect(create_result.result).to eq('pass')

    # read resource created
    stub_request(:get, "#{url}/#{resource_type}/#{resource_id}")
      .to_return(status: 200, body: { resourceType: 'Encounter' }.to_json)
    result = run(runnable, resource_ids: resource_id, url:)
    expect(result.result).to eq('fail')
    expect(entity_result_message.message).to match(/Expected resource type to be: `"Observation"`/)
  end

  it 'fails when reading a resource just created that has a different id than the requested one' do
    # create
    stub_request(:post, "#{url}/#{resource_type}/#{observation}")
      .to_return(status: 200, body: observation)
    create_result = run(runnable, resource_list: observation, url:)
    expect(create_result.result).to eq('pass')

    # read resource created
    stub_request(:get, "#{url}/#{resource_type}/abc")
      .to_return(status: 200, body: observation.to_json)
    result = run(runnable, resource_ids: 'abc', url:)
    expect(result.result).to eq('fail')
    expect(entity_result_message.message).to match(/Expected resource to have request body/)
  end
end
