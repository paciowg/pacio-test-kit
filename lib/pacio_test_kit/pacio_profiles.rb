module PacioTestKit
  module PacioProfiles
    PACIO_PROFILES = {
      'PFEClinicalTestObservation' => 'http://hl7.org/fhir/us/pacio-pfe/StructureDefinition/pfe-observation-clinicaltest',
      'PFECollection' => 'http://hl7.org/fhir/us/pacio-pfe/StructureDefinition/pfe-collection',
      'PFEConditionEncounterDiagnosis' => 'http://hl7.org/fhir/us/pacio-pfe/StructureDefinition/pfe-condition-encounter-diagnosis',
      'PFEConditionProblemsHealthConcerns' => 'http://hl7.org/fhir/us/pacio-pfe/StructureDefinition/pfe-condition-problems-health-concerns',
      'PFEUseOfDevice' => 'http://hl7.org/fhir/us/pacio-pfe/StructureDefinition/pfe-use-of-device',
      'PFENarrativeHistoryOfStatus' => 'http://hl7.org/fhir/us/pacio-pfe/StructureDefinition/pfe-narrative-history-of-status',
      'PFEDiagnosticReportNoteExchange' => 'http://hl7.org/fhir/us/pacio-pfe/StructureDefinition/pfe-diagnostic-report-note-exchange',
      'PFEGoal' => 'http://hl7.org/fhir/us/pacio-pfe/StructureDefinition/pfe-goal',
      'PFENutritionOrder' => 'http://hl7.org/fhir/us/pacio-pfe/StructureDefinition/pfe-nutrition-order',
      'PFEServiceRequest' => 'http://hl7.org/fhir/us/pacio-pfe/StructureDefinition/pfe-service-request',
      'PFESingleObservation' => 'http://hl7.org/fhir/us/pacio-pfe/StructureDefinition/pfe-observation-single',
      'ADICompositionHeader' => 'http://hl7.org/fhir/us/pacio-adi/StructureDefinition/ADI-Composition-Header',
      'ADIPACPComposition' => 'http://hl7.org/fhir/us/pacio-adi/StructureDefinition/ADI-PACPComposition',
      'ADIPMOComposition' => 'http://hl7.org/fhir/us/pacio-adi/StructureDefinition/ADI-PMOComposition',
      'ADIParticipantConsent' => 'http://hl7.org/fhir/us/pacio-adi/StructureDefinition/ADI-ParticipantConsent',
      'ADIDocumentReference' => 'http://hl7.org/fhir/us/pacio-adi/StructureDefinition/ADI-DocumentReference',
      'ADIPersonalGoal' => 'http://hl7.org/fhir/us/pacio-adi/StructureDefinition/ADI-PersonalGoal',
      'ADIPersonalPrioritiesOrganizer' => 'http://hl7.org/fhir/us/pacio-adi/StructureDefinition/ADI-PersonalPrioritiesOrganizer',
      'ADIAutopsyObservation' => 'http://hl7.org/fhir/us/pacio-adi/StructureDefinition/ADI-AutopsyObservation',
      'ADIDocumentationObservation' => 'http://hl7.org/fhir/us/pacio-adi/StructureDefinition/ADI-DocumentationObservation',
      'ADIOrganDonationObservation' => 'http://hl7.org/fhir/us/pacio-adi/StructureDefinition/ADI-OrganDonationObservation',
      'ADIPMOHospiceObservation' => 'http://hl7.org/fhir/us/pacio-adi/StructureDefinition/ADI-PMOHospiceObservation',
      'ADIPMOParticipantObservation' => 'http://hl7.org/fhir/us/pacio-adi/StructureDefinition/ADI-PMOParticipantObservation',
      'ADIPMOReviewObservation' => 'http://hl7.org/fhir/us/pacio-adi/StructureDefinition/ADI-PMOReviewObservation',
      'ADICareExperiencePreference' => 'http://hl7.org/fhir/us/pacio-adi/StructureDefinition/ADI-CareExperiencePreference',
      'ADIPersonalInterventionPreference' => 'http://hl7.org/fhir/us/pacio-adi/StructureDefinition/ADI-PersonalInterventionPreference',
      'USCoreOrganization' => 'http://hl7.org/fhir/us/core/StructureDefinition/us-core-organization',
      'USCorePatient' => 'http://hl7.org/fhir/us/core/StructureDefinition/us-core-patient',
      'ADIProvenance' => 'http://hl7.org/fhir/us/pacio-adi/StructureDefinition/ADI-Provenance',
      'ADIWitness' => 'http://hl7.org/fhir/us/pacio-adi/StructureDefinition/ADI-Witness',
      'ADIParticipant' => 'http://hl7.org/fhir/us/pacio-adi/StructureDefinition/ADI-Participant',
      'ADINotary' => 'http://hl7.org/fhir/us/pacio-adi/StructureDefinition/ADI-Notary',
      'ADIPMOServiceRequest' => 'http://hl7.org/fhir/us/pacio-adi/StructureDefinition/ADI-PMOServiceRequest',
      'TOCComposition' => 'http://hl7.org/fhir/us/pacio-toc/StructureDefinition/TOC-Composition'
    }.freeze

    PFE_RESOURCES = {
      'Patient' => ['http://hl7.org/fhir/us/core/StructureDefinition/us-core-patient'].freeze,
      'Observation' => [
        'http://hl7.org/fhir/us/pacio-pfe/StructureDefinition/pfe-observation-clinicaltest',
        'http://hl7.org/fhir/us/pacio-pfe/StructureDefinition/pfe-collection',
        'http://hl7.org/fhir/us/pacio-pfe/StructureDefinition/pfe-observation-single'
      ].freeze,
      'DiagnosticReport' => [
        'http://hl7.org/fhir/us/pacio-pfe/StructureDefinition/pfe-narrative-history-of-status',
        'http://hl7.org/fhir/us/pacio-pfe/StructureDefinition/pfe-diagnostic-report-note-exchange'
      ].freeze,
      'DeviceUseStatement' => ['http://hl7.org/fhir/us/pacio-pfe/StructureDefinition/pfe-use-of-device'].freeze,
      'Condition' => [
        'http://hl7.org/fhir/us/pacio-pfe/StructureDefinition/pfe-condition-encounter-diagnosis',
        'http://hl7.org/fhir/us/pacio-pfe/StructureDefinition/pfe-condition-problems-health-concerns'
      ].freeze,
      'Goal' => ['http://hl7.org/fhir/us/pacio-pfe/StructureDefinition/pfe-goal'].freeze,
      'NutritionOrder' => ['http://hl7.org/fhir/us/pacio-pfe/StructureDefinition/pfe-nutrition-order'].freeze,
      'ServiceRequest' => ['http://hl7.org/fhir/us/pacio-pfe/StructureDefinition/pfe-service-request'].freeze
    }.freeze

    ADI_RESOURCES = {
      'Bundle' => [].freeze,
      'Composition' => [
        'http://hl7.org/fhir/us/pacio-adi/StructureDefinition/ADI-Composition-Header',
        'http://hl7.org/fhir/us/pacio-adi/StructureDefinition/ADI-PACPComposition',
        'http://hl7.org/fhir/us/pacio-adi/StructureDefinition/ADI-PMOComposition'
      ].freeze,
      'Consent' => [
        'http://hl7.org/fhir/us/pacio-adi/StructureDefinition/ADI-ParticipantConsent'
      ].freeze,
      'DocumentReference' => ['http://hl7.org/fhir/us/pacio-adi/StructureDefinition/ADI-DocumentReference'].freeze,
      'Goal' => ['http://hl7.org/fhir/us/pacio-adi/StructureDefinition/ADI-PersonalGoal'].freeze,
      'List' => ['http://hl7.org/fhir/us/pacio-adi/StructureDefinition/ADI-PersonalPrioritiesOrganizer'].freeze,
      'Observation' => [
        'http://hl7.org/fhir/us/pacio-adi/StructureDefinition/ADI-DocumentationObservation',
        'http://hl7.org/fhir/us/pacio-adi/StructureDefinition/ADI-PersonalInterventionPreference',
        'http://hl7.org/fhir/us/pacio-adi/StructureDefinition/ADI-OrganDonationObservation',
        'http://hl7.org/fhir/us/pacio-adi/StructureDefinition/ADI-AutopsyObservation',
        'http://hl7.org/fhir/us/pacio-adi/StructureDefinition/ADI-CareExperiencePreference',
        'http://hl7.org/fhir/us/pacio-adi/StructureDefinition/ADI-PMOHospiceObservation',
        'http://hl7.org/fhir/us/pacio-adi/StructureDefinition/ADI-PMOParticipantObservation',
        'http://hl7.org/fhir/us/pacio-adi/StructureDefinition/ADI-PMOReviewObservation'
      ].freeze,
      'Organization' => ['http://hl7.org/fhir/us/core/StructureDefinition/us-core-organization'].freeze,
      'Patient' => ['http://hl7.org/fhir/us/core/StructureDefinition/us-core-patient'].freeze,
      'Provenance' => ['http://hl7.org/fhir/us/pacio-adi/StructureDefinition/ADI-Provenance'].freeze,
      'RelatedPerson' => [
        'http://hl7.org/fhir/us/pacio-adi/StructureDefinition/ADI-Witness',
        'http://hl7.org/fhir/us/pacio-adi/StructureDefinition/ADI-Participant',
        'http://hl7.org/fhir/us/pacio-adi/StructureDefinition/ADI-Notary'
      ].freeze,
      'ServiceRequest' => [
        'http://hl7.org/fhir/us/pacio-adi/StructureDefinition/ADI-PMOServiceRequest',
        'http://hl7.org/fhir/us/pacio-adi/StructureDefinition/ADI-PMOMedicallyAssistedNutritionServiceRequest',
        'http://hl7.org/fhir/us/pacio-adi/StructureDefinition/ADI-PMOMedicallyAssistedHydrationServiceRequest',
        'http://hl7.org/fhir/us/pacio-adi/StructureDefinition/ADI-PMOInitialTreatmentServiceRequest',
        'http://hl7.org/fhir/us/pacio-adi/StructureDefinition/ADI-PMOCPRServiceRequest',
        'http://hl7.org/fhir/us/pacio-adi/StructureDefinition/ADI-PMOAdditionalOrdersOrInstructionsServiceRequest'
      ].freeze
    }.freeze

    TOC_RESOURCES = {
      'Bundle' => [].freeze,
      'Composition' => [
        'http://hl7.org/fhir/us/pacio-toc/StructureDefinition/TOC-Composition'
      ].freeze,
      'Organization' => [].freeze,
      'Patient' => [
        'http://hl7.org/fhir/us/core/StructureDefinition-us-core-patient|6.1.0'
      ].freeze,
      'OperationDefinition' => [
        'http://hl7.org/fhir/R4/patient-operation-match'
      ].freeze
    }.freeze

  end
end
