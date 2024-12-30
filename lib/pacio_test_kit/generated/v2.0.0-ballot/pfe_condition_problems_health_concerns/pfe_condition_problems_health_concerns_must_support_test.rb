require_relative '../../../must_support_test'
require_relative '../../../generator/group_metadata'

module PacioTestKit
  module PFEV200_BALLOT
    class PfeConditionProblemsHealthConcernsMustSupportTest < Inferno::Test
      include PacioTestKit::MustSupportTest

      title 'All must support elements are provided in the Condition resources returned'
      description %(
        PFE Responders SHALL be capable of populating all data elements as
        part of the query results as specified by the US Core Server Capability
        Statement. This test will look through the Condition resources
        found previously for the following must support elements:

        * Condition.abatementDateTime
        * Condition.asserter
        * Condition.bodySite
        * Condition.category
        * Condition.category:screening-assessment
        * Condition.category:us-core
        * Condition.clinicalStatus
        * Condition.code
        * Condition.extension:assertedDate
        * Condition.onsetDateTime
        * Condition.recordedDate
        * Condition.subject
        * Condition.verificationStatus
      )

      id :pfe_v200_ballot_pfe_condition_problems_health_concerns_must_support_test

      def resource_type
        'Condition'
      end

      def self.metadata
        @metadata ||= Generator::GroupMetadata.new(YAML.load_file(File.join(__dir__, 'metadata.yml'), aliases: true))
      end

      def scratch_resources
        scratch[:pfe_condition_problems_health_concerns_resources] ||= {}
      end

      run do
        perform_must_support_test(all_scratch_resources)
      end
    end
  end
end
