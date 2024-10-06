module PacioTestKit
  class DeletedResourceErrorTest < Inferno::Test
    title 'Server returns 410 response when making a read request to a deleted resource.'
    id :pacio_deleted_resource_error
    description %(
      This test verifies that a server returns a 410 response when
      attempting to read a deleted resource.
    )
    input :resource_ids,
          title: 'ID(s) for deleted resources from the server',
          description: 'If providing multiple IDs, separate them by a comma and a space. e.g. id_1, id_2, id_3'

    input :resource_types,
          title: 'Resource type(s) for the deleted resources from the server',
          description: 'If providing multiple types, separate them by a comma and a space. e.g. type_1, type_2, type_3'

    run do
      id_list = resource_ids.split(',').map(&:strip)
      resource_ids = [id_list].flatten

      type_list = resource_types.split(',').map(&:strip)
      resource_types = [type_list].flatten

      resource_ids.each_with_index do |id, index|
        fhir_read(resource_types[index], id)
        assert_response_status(410)
        assert_resource_type('OperationOutcome')
      end
    end
  end
end
