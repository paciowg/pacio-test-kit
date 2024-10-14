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
      description %(

      # Background

      The PACIO PFE Nutrition Order Profile tests verify that the system under test is able to provide
      correct responses for NutritionOrder queries. These queries must contain resources conforming to the
      Nutrition Order Profile as specified in the PACIO Personal Functioning and Engagement (PFE) IG
      v2.0.0 Implementation Guide.

      # Testing Methodology

      ## Reading
      The read interaction will perform required read associated with ID(s) provided by a user for NutritionOrder
      resources present on the server. The resources returned from the read requests are validated on status,
      resource JSON structure, resource type, and matching ID values to the user provided ID(s).

      ## Profile Validation
      Each resource returned from the first read is expected to conform to the Nutrition Order Profile. Each
      element is checked against terminology binding and cardinality requirements. Elements with a required binding
      are validated against their bound ValueSet. If a code/system in the element is not part of the ValueSet, then
      the test will fail.

      ## Must Support
      TODO

      )
      # description adapted from US-Core-Test-Kit groups: https://github.com/inferno-framework/us-core-test-kit
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
                 optional: true,
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
