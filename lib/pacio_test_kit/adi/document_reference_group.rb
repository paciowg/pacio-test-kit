require_relative '../common_tests/read_test'
require_relative '../common_tests/validation_test'
require_relative '../pacio_profiles'
require_relative '../common_tests/adi_search_tests/document_reference_tests/documentref__id_search_test'
require_relative '../common_tests/adi_search_tests/document_reference_tests/documentref_custodian_search_test'
require_relative '../common_tests/adi_search_tests/document_reference_tests/documentref_date_search_test'
require_relative '../common_tests/adi_search_tests/document_reference_tests/documentref_identifier_search_test'
require_relative '../common_tests/adi_search_tests/document_reference_tests/documentref_patient_search_test'
require_relative '../common_tests/adi_search_tests/document_reference_tests/documentref_period_search_test'
require_relative '../common_tests/adi_search_tests/document_reference_tests/documentref_status_search_test'
require_relative '../common_tests/adi_search_tests/document_reference_tests/documentref_type_search_test'
require_relative '../common_tests/adi_search_tests/id_search_test'

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
      test from: :document_ref__id_search_test,
           title: 'Server returns valid results for DocumentReference search by _id'
      test from: :document_ref_custodian_search_test,
           title: 'Server returns valid results for DocumentReference search by custodian'
      test from: :document_ref_date_search_test,
           title: 'Server returns valid results for DocumentReference search by date'
      test from: :document_ref_identifier_search_test,
           title: 'Server returns valid results for DocumentReference search by identifier'
      test from: :document_ref_patient_search_test,
           title: 'Server returns valid results for DocumentReference search by patient'
      test from: :document_ref_period_search_test,
           title: 'Server returns valid results for DocumentReference search by period'
      test from: :document_ref_status_search_test,
           title: 'Server returns valid results for DocumentReference search by status'
      test from: :document_ref_type_search_test,
           title: 'Server returns valid results for DocumentReference search by type'
      test from: :pacio_resource_validation,
           title: 'DocumentReference Resources returned in previous tests conform to the ADIDocumentReference profile',
           description: ERB.new(File.read(File.expand_path(
                                            '../../docs/validation_test_description.md.erb', __dir__
                                          ))).result_with_hash(
                                            config:,
                                            pacio_profiles: PACIO_PROFILES
                                          )
    end
  end
end
