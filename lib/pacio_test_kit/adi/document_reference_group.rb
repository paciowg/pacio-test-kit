require_relative '../common_tests/read_test'

module PacioTestKit
  module ADI
    class DocumentReferenceGroup < Inferno::TestGroup
      title 'ADI Document Reference Tests'
      id :pacio_adi_document_reference
      description %(
        Verify support for the server capabilities required by the
        PACIO ADI Document Reference Profile
      )

      config options: {
        resource_type: 'DocumentReference',
        profile: 'ADIDocumentReference'
      }
      run_as_group
      input_order :url

      test from: :pacio_resource_read,
           title: 'Server returns correct DocumentReference resource from read interaction',
           config: {
             inputs: {
               resource_ids: {
                 name: :document_reference_resource_ids,
                 title: 'ID(s) for ADIDocumentReference resources present on the server'
               }
             }
           }
    end
  end
end
