require_relative '../interactions_test'

module PacioTestKit
  class ReadTest < Inferno::Test
    include PacioTestKit::InteractionsTest

    title 'Server returns correct resource from read interaction'
    id :pacio_resource_read
    description 'A server SHALL support the read interaction.'

    input :resource_ids,
          title: "ID(s) for #{config.options[:profile]} resources present on the server",
          description: 'If providing multiple IDs, separate them by a comma and a space. e.g. id_1, id_2, id_3'

    def resource_type
      config.options[:resource_type]
    end

    def tag
      config.options[:profile]
    end

    run do
      id_list = resource_ids.split(',').map(&:strip)
      read_and_validate_resources(id_list, tag)

      no_error_validation("Fail to read #{resource_type} resource(s). See error messages for details.")
    end
  end
end
