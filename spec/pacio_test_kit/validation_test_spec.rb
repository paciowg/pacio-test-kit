RSpec.describe PacioTestKit::ValidationTest do
  let(:runnable) { Inferno::Repositories::Tests.new.find('pacio_resource_validation') }
  let(:session_data_repo) { Inferno::Repositories::SessionData.new }
  let(:results_repo) { Inferno::Repositories::Results.new }
  let(:suite_id) { 'pacio_pfe_server' }
  let(:test_session) { repo_create(:test_session, test_suite_id: 'pacio_pfe_server') }
  let(:url) { 'https://example/r4' }
  let(:resource_type) { 'Observation' }
  let(:resource_id) { '123' }
  let(:profile) { 'PFESingleObservation' }
  let(:observation) do
    JSON.parse(
      File.read(File.join(__dir__, '..', 'fixtures', 'pfe_single_observation.json'))
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
      headers:
    )
  end

  def mock_server(body: nil, status: 200, valid_resource: false)
    request = build_read_request(body:, status:)
    allow_any_instance_of(runnable).to receive(:load_tagged_requests).and_return([request])
    allow_any_instance_of(runnable).to receive(:resource_is_valid?).and_return(valid_resource)
    messages = [{ type: 'error', message: 'resource not conformant' }]
    allow_any_instance_of(runnable).to receive(:messages).and_return(messages) unless valid_resource
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

  before do
    allow_any_instance_of(runnable).to receive(:resource_type).and_return(resource_type)
    allow_any_instance_of(runnable).to receive(:tag).and_return(profile)
  end

  it 'passes when at least one previous read request is successful and returns conformant resource' do
    mock_server(body: observation, valid_resource: true)
    result = run(runnable)
    expect(result.result).to eq('pass')
  end

  it 'skips when no read requests were made in previous tests' do
    result = run(runnable)
    expect(result.result).to eq('skip')
    expect(result.result_message).to match(%r{No #{profile} resource read/search request was made in previous tests})
  end

  it 'skips when all read requests were unsuccessful' do
    mock_server(status: 401, valid_resource: true)
    result = run(runnable)
    expect(result.result).to eq('skip')
    expect(result.result_message).to match(%r{read/search requests were unsuccessful})
  end

  it 'fails if at least one of the returned resources is not conformant to the given profile' do
    mock_server(body: { resourceType: resource_type })
    result = run(runnable)

    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/resources returned in previous tests do not conform to the profile/)
  end
end
