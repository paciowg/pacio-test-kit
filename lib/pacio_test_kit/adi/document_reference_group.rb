require_relative '../common_tests/read_test'
require_relative '../common_tests/validation_test'
require_relative '../pacio_profiles'
require_relative '../common_tests/update_test'

module PacioTestKit
  module ADI
    class DocumentReferenceGroup < Inferno::TestGroup
      include PacioTestKit::PacioProfiles

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
      test from: :pacio_resource_validation,
           title: 'DocumentReference Resources returned in previous tests conform to the ADIDocumentReference profile',
           description: ERB.new(File.read(File.expand_path(
                                            '../../docs/validation_test_description.md.erb', __dir__
                                          ))).result_with_hash(
                                            config:,
                                            pacio_profiles: PACIO_PROFILES
                                          )
      test from: :pacio_resource_update
    end
  end
end
