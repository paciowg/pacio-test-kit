RSpec.describe PacioTestKit::SearchTypeTest do
  let(:runnable) do
    Class.new(PacioTestKit::SearchTypeTest) do
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
  let(:resource_category) { 'category_name|category_code' }
  let(:resource_code) { 'code_name|code_value' }
  let(:resource_date) { 'gedate_value' }
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

  it 'passes when search by patient and category is successful and correct resource is retrieved' do
    stub_request(:get, "#{url}/#{resource_type}?patient=#{resource_id}&category=#{resource_category}")
      .to_return(status: 200, body: observation_search_response.to_json)

    stub_request(:post, "#{url}/#{resource_type}/_search")
      .with(body: { patient: resource_id, category: resource_category })
      .to_return(status: 200, body: observation_search_response.to_json)

    result = run(runnable, patient: resource_id, category: resource_category, url:)
    expect(result.result).to eq('pass')
  end

  it 'passes when search by patient, category, and date is successful and correct resource is retrieved' do
    stub_request(:get,
                 "#{url}/#{resource_type}?patient=#{resource_id}&category=#{resource_category}&date=#{resource_date}")
      .to_return(status: 200, body: observation_search_response.to_json)

    stub_request(:post, "#{url}/#{resource_type}/_search").with(body:
    { patient: resource_id, category: resource_category, date: resource_date })
      .to_return(status: 200, body: observation_search_response.to_json)

    result = run(runnable, patient: resource_id, category: resource_category, date: resource_date, url:)
    expect(result.result).to eq('pass')
  end

  it 'passes when search by patient and code is successful and correct resource is retrieved' do
    stub_request(:get, "#{url}/#{resource_type}?patient=#{resource_id}&code=#{resource_code}")
      .to_return(status: 200, body: observation_search_response.to_json)

    stub_request(:post, "#{url}/#{resource_type}/_search").with(body: { patient: resource_id, code: resource_code })
      .to_return(status: 200, body: observation_search_response.to_json)

    result = run(runnable, patient: resource_id, code: resource_code, url:)
    expect(result.result).to eq('pass')
  end

  it 'fails when response status is not 200' do
    stub_request(:get, "#{url}/#{resource_type}?patient=#{resource_id}&code=#{resource_code}")
      .to_return(status: 500, body: {}.to_json)

    result = run(runnable, patient: resource_id, code: resource_code, url:)
    expect(result.result).to eq('fail')
  end

  it 'fails when response type is not fhir bundle' do
    stub_request(:get, "#{url}/#{resource_type}?patient=#{resource_id}&code=#{resource_code}")
      .to_return(status: 200, body: { resourceType: 'Observation' }.to_json)

    result = run(runnable, patient: resource_id, code: resource_code, url:)
    expect(result.result).to eq('fail')
  end

  it 'fails when response resource does not have type searchset' do
    stub_request(:get, "#{url}/#{resource_type}?patient=#{resource_id}&code=#{resource_code}")
      .to_return(status: 200, body: { resourceType: 'Bundle', type: 'notSearchSet' }.to_json)

    result = run(runnable, patient: resource_id, code: resource_code, url:)
    expect(result.result).to eq('fail')
  end
end
