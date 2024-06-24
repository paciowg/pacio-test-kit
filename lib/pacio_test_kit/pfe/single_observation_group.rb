require_relative '../common_tests/read_test'
require_relative '../common_tests/create_test'
require_relative 'single_observation/single_observation_validation_test'

module PacioTestKit
  module PFE
    class SingleObservationGroup < Inferno::TestGroup
      title 'Single Observation Tests'
      id :pacio_pfe_single_observation
      short_description %(
        Verify support for the server capabilities required by the PACIO PFE Single Observation Profile.
      )
      description 'TODO: Add description'

      let(:default_example_resource) do
        example_files = ['Observation-1.json']

        example_files.each_with_index do |file, index|
          example_files[index] = JSON.parse(File.read(File.join(__dir__, '..', 'example_resources', 'pfe', 'single_observation_examples', file)))
        
        return example_files
      end

      config options: {
        resource_type: 'Observation',
        profile: 'PFESingleObservation'
      }
      run_as_group
      input_order :url

      test from: :pacio_resource_create,
           title: 'Server creates correct Observation resource from Observation create interaction',
           config: {
             inputs: {
               resource_list: {
                 name: :default_example_resource,
                 title: 'Default resource(s) for PFESingleObservation to create on the server'
               }
             }
           }
      test from: :pacio_resource_read,
           title: 'Server returns correct Observation resource from Observation read interaction',
           config: {
             inputs: {
               resource_ids: {
                 name: :single_observation_resource_ids,
                 title: 'ID(s) for PFESingleObservation resources present on the server'
               }
             }
           }
      test from: :pacio_pfe_single_observation_validation
    end
  end
end
