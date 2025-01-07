require_relative '../../../must_support_test'
require_relative '../../../generator/group_metadata'

module PacioTestKit
  module PFEV200_BALLOT
    class PfeCollectionMustSupportTest < Inferno::Test
      include PacioTestKit::MustSupportTest

      title 'All must support elements are provided in the Observation resources returned'
      description %(
        PFE Responders SHALL be capable of populating all data elements as
        part of the query results as specified by the US Core Server Capability
        Statement. This test will look through the Observation resources
        found previously for the following must support elements:

        * Observation.category
        * Observation.category:PFEDomain
        * Observation.category:survey
        * Observation.category:us-core
        * Observation.code
        * Observation.derivedFrom
        * Observation.effectiveDateTime
        * Observation.extension:device-use
        * Observation.extension:event-location
        * Observation.hasMember
        * Observation.performer
        * Observation.status
        * Observation.subject
        * Observation.valueBoolean
        * Observation.valueCodeableConcept
        * Observation.valueQuantity
        * Observation.valueString
      )

      id :pfe_v200_ballot_pfe_collection_must_support_test

      def resource_type
        'Observation'
      end

      def self.metadata
        @metadata ||= Generator::GroupMetadata.new(YAML.load_file(File.join(__dir__, 'metadata.yml'), aliases: true))
      end

      def scratch_resources
        scratch[:pfe_collection_resources] ||= {}
      end

      run do
        perform_must_support_test(all_scratch_resources)
      end
    end
  end
end
