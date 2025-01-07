RSpec.describe PacioTestKit::MustSupportTest do
  let(:session_data_repo) { Inferno::Repositories::SessionData.new }
  let(:results_repo) { Inferno::Repositories::Results.new }
  let(:test_session) { repo_create(:test_session, test_suite_id: 'pacio_pfe_server') }

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

  describe 'must support test for single observation' do
    let(:observation_must_support_test) do
      Inferno::Repositories::Tests.new.find('pfe_v200_ballot_pfe_observation_single_must_support_test')
    end
    let(:perfect_observation) do
      FHIR::Observation.new(
        id: '123',
        extension: [{ url: 'http://hl7.org/fhir/us/pacio-pfe/StructureDefinition/event-location',
                      valueReference: { reference: 'Location/example-location-1' } },
                    { url: 'http://hl7.org/fhir/us/pacio-pfe/StructureDefinition/device-patient-used',
                      valueReference: { reference: 'Device/example-device-1' } }],
        status: 'final',
        category: [
          { coding: [
            { system: 'http://hl7.org/fhir/us/core/CodeSystem/us-core-category',
              code: 'cognitive-status' }
          ] },
          { coding: [
            { system: 'http://hl7.org/fhir/us/pacio-pfe/CodeSystem/pfe-category-cs',
              code: 'BlockL1-d11' }
          ] },
          { coding: [
            { system: 'http://terminology.hl7.org/CodeSystem/observation-category',
              code: 'survey' }
          ] }
        ],
        code: { coding: [{ system: 'http://loinc.org', code: '54628-3',
                           display: 'Inattention in last 7 days [CAM.CMS]' }] },
        subject: { reference: 'Patient/PFEIG-patientBSJ1' },
        effectiveDateTime: '2020-04-09T18:00:00-05:00',
        performer: [{ reference: 'PractitionerRole/PFEIG-Role-SLP-HoneyJones' }],
        valueQuantity: { value: '25', units: 'sec', system: 'http://unitsofmeasure.org', code: 's' },
        valueBoolean: 'true',
        valueString: 'some string',
        valueCodeableConcept: { coding: [{ system: 'http://loinc.org', code: 'LA61-7', display: 'Behavior not present' }] }
      )
    end

    it 'passes when server supports all MS elements' do
      allow_any_instance_of(observation_must_support_test).to receive(:scratch_resources).and_return(
        {
          all: [perfect_observation]
        }
      )

      result = run(observation_must_support_test)
      expect(result.result).to eq('pass')
    end

    it 'skips when server does not support one MS element' do
      perfect_observation.effectiveDateTime = nil
      allow_any_instance_of(observation_must_support_test).to receive(:scratch_resources).and_return(
        {
          all: [perfect_observation]
        }
      )

      result = run(observation_must_support_test)
      expect(result.result).to eq('skip')
      expect(result.result_message).to include('effectiveDateTime')
    end
  end
end
