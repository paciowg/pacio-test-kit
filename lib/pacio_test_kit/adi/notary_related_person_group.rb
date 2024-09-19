require_relative '../common_tests/read_test'
require_relative '../common_tests/validation_test'
require_relative '../pacio_profiles'

module PacioTestKit
  module ADI
    class NotaryRelatedPersonGroup < Inferno::TestGroup
      include PacioTestKit::PacioProfiles

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
      test from: :pacio_resource_validation,
           title: 'RelatedPerson Resources returned in previous tests conform to the ADINotary profile',
           description: ERB.new(File.read(File.expand_path(
                                            '../../docs/validation_test_description.md.erb', __dir__
                                          ))).result_with_hash(
                                            config:,
                                            pacio_profiles: PACIO_PROFILES
                                          )
    end
  end
end
