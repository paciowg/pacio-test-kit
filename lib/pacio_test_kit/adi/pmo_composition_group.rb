require_relative '../common_tests/read_test'

module PacioTestKit
  module ADI
    class PMOCompositionGroup < Inferno::TestGroup
      title 'ADI PMO Composition Tests'
      id :pacio_adi_pmo_composition
      description %(
        Verify support for the server capabilities required by the
        PACIO ADI Portable Medical Order Composition Profile
      )
      optional

      config options: {
        resource_type: 'Composition',
        profile: 'ADIPMOComposition'
      }
      run_as_group
      input_order :url

      test from: :pacio_resource_read,
           title: 'Server returns correct Composition resource from read interaction',
           optional: true,
           config: {
             inputs: {
               resource_ids: {
                 name: :pmo_composition_resource_ids,
                 optional: true,
                 title: 'ID(s) for ADIPMOComposition resources present on the server'
               }
             }
           }
    end
  end
end
