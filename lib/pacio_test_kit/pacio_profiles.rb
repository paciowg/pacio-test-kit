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
      'PFESingleObservation' => 'http://hl7.org/fhir/us/pacio-pfe/StructureDefinition/pfe-observation-single'
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
        'https://hl7.org/fhir/us/pacio-adi/StructureDefinition-ADI-Composition-Header.html',
        'https://hl7.org/fhir/us/pacio-adi/StructureDefinition-ADI-PACPComposition.html'
      ].freeze,
      'Consent' => [
        'https://hl7.org/fhir/us/pacio-adi/StructureDefinition-ADI-HealthcareAgentAuthority.html',
        'https://hl7.org/fhir/us/pacio-adi/StructureDefinition-ADI-ConsentForHealthcareAgent.html'
      ].freeze,
      'DocumentReference' => ['https://hl7.org/fhir/us/pacio-adi/StructureDefinition-ADI-DocumentReference.html'].freeze,
      'Goal' => ['https://hl7.org/fhir/us/pacio-adi/StructureDefinition-ADI-PersonalGoal.html'].freeze,
      'List' => ['https://hl7.org/fhir/us/pacio-adi/StructureDefinition-ADI-PersonalPrioritiesOrganizer.html'].freeze,
      'Observation' => [
        'https://hl7.org/fhir/us/pacio-adi/StructureDefinition-ADI-DocumentationObservation.html',
        'https://hl7.org/fhir/us/pacio-adi/StructureDefinition-ADI-PersonalInterventionPreference.html',
        'https://hl7.org/fhir/us/pacio-adi/StructureDefinition-ADI-OrganDonationObservation.html',
        'https://hl7.org/fhir/us/pacio-adi/StructureDefinition-ADI-AutopsyObservation.html',
        'https://hl7.org/fhir/us/pacio-adi/StructureDefinition-ADI-CareExperiencePreference.html'
      ].freeze,
      'Organization' => [].freeze,
      'Patient' => ['https://www.hl7.org/fhir/us/core/StructureDefinition-us-core-patient.html'].freeze,
      'Provenance' => ['https://hl7.org/fhir/us/pacio-adi/StructureDefinition-ADI-Provenance.html'].freeze,
      'RelatedPerson' => [
        'https://hl7.org/fhir/us/pacio-adi/StructureDefinition-ADI-HealthcareAgent.html',
        'https://hl7.org/fhir/us/pacio-adi/StructureDefinition-ADI-Guardian.html'
      ].freeze
    }.freeze
  end
end
