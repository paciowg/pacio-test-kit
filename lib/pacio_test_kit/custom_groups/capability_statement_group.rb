require 'tls_test_kit'
require_relative 'capability_statement/conformance_support_test'
require_relative 'capability_statement/fhir_version_test'
require_relative 'capability_statement/json_support_test'
require_relative 'capability_statement/profile_support_test'

module PacioTestKit
  class CapabilityStatementGroup < Inferno::TestGroup
    include PacioTestKit::PacioProfiles

    title 'Capability Statement'
    id :capability_statement
    short_description %(
      Retrieve information about supported server functionality using the FHIR capabilties interaction.
    )
    run_as_group

    test from: :tls_version_test,
         id: :standalone_auth_tls,
         title: 'FHIR server secured by transport layer security',
         description: %(
             Systems **SHALL** use TLS version 1.2 or higher for all transmissions
             not taking place over a secure network connection.
           ),
         config: {
           options: { minimum_allowed_version: OpenSSL::SSL::TLS1_2_VERSION }
         }
    test from: :ig_conformance_support
    test from: :ig_fhir_version
    test from: :ig_json_support

    test from: :ig_profile_support
  end
end
