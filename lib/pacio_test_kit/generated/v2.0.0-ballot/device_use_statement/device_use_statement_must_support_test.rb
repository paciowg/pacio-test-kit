require_relative '../../../must_support_test'
require_relative '../../../generator/group_metadata'

module PacioTestKit
  module PFEV200_BALLOT
    class DeviceUseStatementMustSupportTest < Inferno::Test
      include PacioTestKit::MustSupportTest

      title 'All must support elements are provided in the DeviceUseStatement resources returned'
      description %(
        PFE Responders SHALL be capable of populating all data elements as
        part of the query results as specified by the US Core Server Capability
        Statement. This test will look through the DeviceUseStatement resources
        found previously for the following must support elements:


      )

      id :pfe_v200_ballot_device_use_statement_must_support_test

      def resource_type
        'DeviceUseStatement'
      end

      def self.metadata
        @metadata ||= Generator::GroupMetadata.new(YAML.load_file(File.join(__dir__, 'metadata.yml'), aliases: true))
      end

      def scratch_resources
        scratch[:device_use_statement_resources] ||= {}
      end

      run do
        perform_must_support_test(all_scratch_resources)
      end
    end
  end
end
