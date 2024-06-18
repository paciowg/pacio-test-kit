module PacioTestKit
  module InteractionsTest
    # TODO: All helper methods for interactions tests (CRUD) will be added here.

    def read_and_validate_resources(resource_ids, tag = '')
      resource_ids = [resource_ids].flatten
      resource_ids.each_with_index do |id, index|
        req_num = index + 1
        fhir_read(resource_type, id, tags: [tag])

        status = request.response[:status]
        next unless validate_status(status, req_num)

        next unless validate_json(request.response_body, req_num)

        next unless validate_resource_type(resource, req_num)

        validate_resource_id(resource, id, req_num)
      end
    end

    def validate_status(status, req_num)
      if status == 200
        true
      else
        status_error_msg = "Request-#{req_num}: Unexpected response status: expected 200, but received #{status}"
        add_message('error', status_error_msg)
        false
      end
    end

    def validate_json(response_body, req_num)
      if valid_json?(response_body)
        true
      else
        add_message('error', "Request-#{req_num}: Response is not a valid JSON")
        false
      end
    end

    def validate_resource_type(resource, req_num)
      if resource.resourceType == resource_type
        true
      else
        add_message('error', bad_resource_type_message(resource_type, req_num))
        false
      end
    end

    def validate_resource_id(resource, id, req_num)
      return if resource.id == id

      add_message('error', bad_resource_id_message(id, req_num))
    end

    def valid_json?(json)
      JSON.parse(json)
      true
    rescue JSON::ParserError
      false
    end

    def bad_resource_id_message(expected_id, request_num = nil)
      prefix = request_num.present? ? "Request-#{request_num}: " : ''
      "#{prefix}Expected resource to have id `#{expected_id.inspect}`, but found `#{resource.id.inspect}`"
    end

    def bad_resource_type_message(expected_resource_type, request_num = nil)
      prefix = request_num.present? ? "Request-#{request_num}: " : ''
      "#{prefix}Expected resource type to be: `#{expected_resource_type.inspect}`, but found " \
        "`#{resource.resourceType.inspect}`"
    end

    def no_error_validation(message)
      assert messages.none? { |msg| msg[:type] == 'error' }, message
    end
  end
end
