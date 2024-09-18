require_relative '../common_tests/read_test'

module PacioTestKit
  module ADI
    class NotaryRelatedPersonGroup < Inferno::TestGroup
      title 'ADI Notary Related Person Tests'
      id :pacio_adi_notary_related_person
      description %(
        Verify support for the server capabilities required by the
        PACIO ADI Notary Profile
      )
      optional

      config options: {
        resource_type: 'RelatedPerson',
        profile: 'ADINotary'
      }
      run_as_group
      input_order :url

      test from: :pacio_resource_read,
           title: 'Server returns correct RelatedPerson resource from read interaction',
           optional: true,
           config: {
             inputs: {
               resource_ids: {
                 name: :notary_related_person_resource_ids,
                 optional: true,
                 title: 'ID(s) for ADINotary RelatedPerson resources present on the server'
               }
             }
           }
    end
  end
end
