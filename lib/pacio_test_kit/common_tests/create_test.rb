require_relative '../interactions_test'

module PacioTestKit
  class CreateTest < Inferno::Test
    include PacioTestKit::InteractionsTest

    title 'Server makes correct resource from create interaction'
    id :pacio_resource_create
    description 'A server SHALL support the create interaction.'

    input :resource_list,
          title: "Resource(s) for #{config.options[:profile]} created on the server",
          description: 'If providing multiple resources, separate them by a comma and a space. e.g. {r_1}, {r_2}, {r_3}'

    def resource_type
      config.options[:resource_type]
    end

    def tag
      config.options[:profile]
    end

    run do
      resource_list = resource_list.split(',').map(&:strip)
      create_and_validate_resources(resource_list, tag)

      no_error_validation("Fail to read #{resource_type} resource(s). See error messages for details.")
    end
  end
end
