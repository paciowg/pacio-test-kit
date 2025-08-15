require_relative 'error_handling_group'
require_relative 'pacio_profiles'
require_relative 'custom_groups/capability_statement_group'
require_relative 'adi/bundle_group'
require_relative 'adi/composition_header_group'
require_relative 'adi/pacp_composition_group'
require_relative 'adi/pmo_composition_group'
require_relative 'adi/participant_consent_group'
require_relative 'adi/document_reference_group'
require_relative 'adi/personal_goal_group'
require_relative 'adi/personal_priorities_organizer_group'
require_relative 'adi/autopsy_observation_group'
require_relative 'adi/documentation_observation_group'
require_relative 'adi/organ_donation_observation_group'
require_relative 'adi/pmo_hospice_observation_group'
require_relative 'adi/pmo_participant_observation_group'
require_relative 'adi/pmo_review_observation_group'
require_relative 'adi/care_experience_preference_observation_group'
require_relative 'adi/personal_intervention_preference_observation_group'
require_relative 'adi/organization_group'
require_relative 'adi/patient_group'
require_relative 'adi/provenance_group'
require_relative 'adi/witness_related_person_group'
require_relative 'adi/participant_related_person_group'
require_relative 'adi/notary_related_person_group'
require_relative 'adi/pmo_service_request_group'

module PacioTestKit
  class PacioADIServerSuite < Inferno::TestSuite
    include PacioTestKit::PacioProfiles

    id :pacio_adi_server
    title 'PACIO ADI Server Suite v2.0.0-ballot'
    description 'PACIO Advance Directives Server Test Suite'
    ig_url 'http://hl7.org/fhir/us/pacio-adi'
    source_code_url 'https://github.com/paciowg/pacio-test-kit'
    download_url 'https://github.com/paciowg/pacio-test-kit'
    report_issue_url 'https://github.com/paciowg/pacio-test-kit/issues'

    input :url,
          title: 'FHIR Server Base URL'

    input :credentials,
          type: :auth_info,
          title: 'OAuth Credentials',
          options: { mode: 'access' },
          optional: true

    fhir_client do
      url :url
      auth_info :credentials
    end

    fhir_resource_validator do
      igs 'hl7.fhir.us.pacio-adi#2.0.0-ballot', 'hl7.fhir.us.core#8.0.0'

      exclude_message do |message|
        message.message.match?(/\A\S+: \S+: URL value '.*' does not resolve/)
      end
    end

    config(
      options: {
        ig: 'ADI',
        ig_version: '2.0.0-ballot',
        capability_statement_url: 'http://hl7.org/fhir/us/pacio-adi/CapabilityStatement/adi',
        supported_resources: ADI_RESOURCES.keys,
        required_profiles: ADI_RESOURCES.values.flatten
      }
    )

    group do
      title 'ADI FHIR API'

      group from: :capability_statement do
        description ERB.new(File.read(
                              File.expand_path('../docs/capability_statement_group_description.md.erb', __dir__)
                            )).result_with_hash(config:)
      end

      group from: :pacio_adi_bundle
      group from: :pacio_adi_document_reference
      group from: :pacio_adi_organization
      group from: :pacio_adi_patient
      group from: :pacio_adi_composition_header
      group from: :pacio_adi_pacp_composition
      group from: :pacio_adi_pmo_composition
      group from: :pacio_adi_participant_consent
      group from: :pacio_adi_personal_goal
      group from: :pacio_adi_personal_priorities_organizer
      group from: :pacio_adi_autopsy_observation
      group from: :pacio_adi_documentation_observation
      group from: :pacio_adi_organ_donation_observation
      group from: :pacio_adi_pmo_hospice_observation
      group from: :pacio_adi_pmo_participant_observation
      group from: :pacio_adi_pmo_review_observation
      group from: :pacio_adi_care_experience_preference_observation
      group from: :pacio_adi_personal_intervention_preference_observation
      group from: :pacio_adi_provenance
      group from: :pacio_adi_witness_related_person
      group from: :pacio_adi_participant_related_person
      group from: :pacio_adi_notary_related_person
      group from: :pacio_adi_pmo_service_request
      group from: :pacio_error_handling
    end
  end
end
