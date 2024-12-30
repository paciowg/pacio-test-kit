require_relative '../../../must_support_test'
require_relative '../../../generator/group_metadata'

module PacioTestKit
  module PFEV200_BALLOT
    class NutritionOrderMustSupportTest < Inferno::Test
      include PacioTestKit::MustSupportTest

      title 'All must support elements are provided in the NutritionOrder resources returned'
      description %(
        PFE Responders SHALL be capable of populating all data elements as
        part of the query results as specified by the US Core Server Capability
        Statement. This test will look through the NutritionOrder resources
        found previously for the following must support elements:

        * NutritionOrder.encounter
        * NutritionOrder.enteralFormula
        * NutritionOrder.enteralFormula.additiveType
        * NutritionOrder.enteralFormula.administration
        * NutritionOrder.enteralFormula.administration.quantity
        * NutritionOrder.enteralFormula.administration.rate[x]
        * NutritionOrder.enteralFormula.administration.schedule
        * NutritionOrder.enteralFormula.administrationInstruction
        * NutritionOrder.enteralFormula.baseFormulaType
        * NutritionOrder.enteralFormula.caloricDensity
        * NutritionOrder.enteralFormula.routeofAdministration
        * NutritionOrder.excludeFoodModifier
        * NutritionOrder.foodPreferenceModifier
        * NutritionOrder.oralDiet
        * NutritionOrder.oralDiet.fluidConsistencyType
        * NutritionOrder.oralDiet.instruction
        * NutritionOrder.oralDiet.nutrient
        * NutritionOrder.oralDiet.nutrient.amount
        * NutritionOrder.oralDiet.nutrient.modifier
        * NutritionOrder.oralDiet.texture
        * NutritionOrder.oralDiet.texture.foodType
        * NutritionOrder.oralDiet.texture.modifier
        * NutritionOrder.oralDiet.type
        * NutritionOrder.orderer
        * NutritionOrder.supplement
        * NutritionOrder.supplement.instruction
        * NutritionOrder.supplement.quantity
        * NutritionOrder.supplement.schedule
        * NutritionOrder.supplement.type
      )

      id :pfe_v200_ballot_nutrition_order_must_support_test

      def resource_type
        'NutritionOrder'
      end

      def self.metadata
        @metadata ||= Generator::GroupMetadata.new(YAML.load_file(File.join(__dir__, 'metadata.yml'), aliases: true))
      end

      def scratch_resources
        scratch[:nutrition_order_resources] ||= {}
      end

      run do
        perform_must_support_test(all_scratch_resources)
      end
    end
  end
end
