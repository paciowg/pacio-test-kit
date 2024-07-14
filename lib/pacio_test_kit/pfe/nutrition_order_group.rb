require_relative '../common_tests/read_test'
require_relative '../common_tests/validation_test'
require_relative '../pacio_profiles'

module PacioTestKit
  module PFE
    class NutritionOrderGroup < Inferno::TestGroup
      include PacioTestKit::PacioProfiles

      title 'NutritionOrder Tests'
      id :pacio_pfe_nutrition_order
      short_description %(
        Verify support for the server capabilities required by the PACIO PFE Nutrition Order Profile.
      )
      description 'TODO: Add description.'
      optional

      config options: {
        resource_type: 'NutritionOrder',
        profile: 'PFENutritionOrder'
      }
      run_as_group
      input_order :url

      test from: :pacio_resource_read,
           title: 'Server returns correct NutritionOrder resource from NutritionOrder read interaction',
           optional: true,
           config: {
             inputs: {
               resource_ids: {
                 name: :nutrition_order_resource_ids,
                 title: 'ID(s) for PFENutritionOrder resources present on the server'
               }
             }
           }
      test from: :pacio_resource_validation,
           title: 'NutritionOrder Resources returned in previous tests conform to the PFENutritionOrder profile',
           description: ERB.new(File.read(File.join(
                                            'lib', 'docs', 'validation_test_description.md.erb'
                                          ))).result_with_hash(
                                            config:,
                                            pacio_profiles: PACIO_PROFILES
                                          )
    end
  end
end
