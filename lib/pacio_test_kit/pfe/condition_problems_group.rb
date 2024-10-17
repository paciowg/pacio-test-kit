require_relative '../common_tests/read_test'
require_relative '../common_tests/validation_test'
require_relative '../pacio_profiles'

module PacioTestKit
  module PFE
    class ConditionProblemsGroup < Inferno::TestGroup
      include PacioTestKit::PacioProfiles

      title 'Condition Problems Tests'
      id :pacio_pfe_condition_problems
      short_description %(
        Verify support for the server capabilities required by the PACIO PFE Condition Problems
        and Health Concerns Profile.
      )
      description 'TODO: Add description.'
      optional

      config options: {
        resource_type: 'Condition',
        profile: 'PFEConditionProblemsHealthConcerns'
      }
      run_as_group
      input_order :url

      test from: :pacio_resource_read,
           title: 'Server returns correct Condition resource from Condition read interaction',
           optional: true,
           config: {
             inputs: {
               resource_ids: {
                 name: :condition_problems_resource_ids,
                 optional: true,
                 title: 'ID(s) for PFEConditionProblemsHealthConcerns resources present on the server'
               }
             }
           }
      test from: :pacio_resource_validation,
           title: 'Condition Resources returned in previous tests conform to the ' \
                  'PFEConditionProblemsHealthConcerns profile',
           description: ERB.new(File.read(File.expand_path(
                                            '../../docs/validation_test_description.md.erb', __dir__
                                          ))).result_with_hash(
                                            config:,
                                            pacio_profiles: PACIO_PROFILES
                                          )
    end
  end
end
