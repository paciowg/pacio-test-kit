require_relative '../common_tests/read_test'

module PacioTestKit
  module ADI
    class PACPCompositionGroup < Inferno::TestGroup
      title 'ADI PACP Composition Tests'
      id :pacio_adi_pacp_composition
      description %(
        Verify support for the server capabilities required by the
        PACIO ADI Personal Advance Care Plan Composition Profile
      )
      optional

      config options: {
        resource_type: 'Composition',
        profile: 'ADIPACPComposition'
      }
      run_as_group
      input_order :url

      test from: :pacio_resource_read,
           title: 'Server returns correct Composition resource from read interaction',
           optional: true,
           config: {
             inputs: {
               resource_ids: {
                 name: :pacp_composition_resource_ids,
                 optional: true,
                 title: 'ID(s) for ADIPACPComposition resources present on the server'
               }
             }
           }
    end
  end
end
