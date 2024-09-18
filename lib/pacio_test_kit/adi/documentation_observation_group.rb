require_relative '../common_tests/read_test'

module PacioTestKit
  module ADI
    class DocumentationObservationGroup < Inferno::TestGroup
      title 'ADI Documentation Observation Tests'
      id :pacio_adi_documentation_observation
      description %(
        Verify support for the server capabilities required by the
        PACIO ADI Documentation Observation Profile
      )
      optional

      config options: {
        resource_type: 'Observation',
        profile: 'ADIDocumentationObservation'
      }
      run_as_group
      input_order :url

      test from: :pacio_resource_read,
           title: 'Server returns correct Observation resource from read interaction',
           optional: true,
           config: {
             inputs: {
               resource_ids: {
                 name: :documentation_observation_resource_ids,
                 optional: true,
                 title: 'ID(s) for ADIDocumentationObservation resources present on the server'
               }
             }
           }
    end
  end
end
