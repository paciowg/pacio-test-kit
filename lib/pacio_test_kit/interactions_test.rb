module PacioTestKit
  module InteractionsTest
    # TODO: All helper methods for interactions tests (CRUD) will be added here.
    def create_and_validate_resources(resource_list, tag = '')
      # resource_list is list of objects (don't flatten)
      resource_list.each_with_index do |resource, index|
        req_num = index + 1

        # make FHIR resource object
        case resource_type
        when resource_type == 'Observation'
          new_resource = FHIR::Observation.new(resource)
        when resource_type == 'DeviceUseStatement'
          new_resource = FHIR::DeviceUseStatement.new(resource)
        when resource_type == 'DiagnosticReport'
          new_resource = FHIR::DiagnosticReport.new(resource)
        else
          no_resource_created_message(resource_type, req_num)
        end

        # send object to create on server
        fhir_create(new_resource)

        # check 1: validate the resource from the request.response itself
        status = request.response[:status]
        next unless validate_status(status, req_num)
        next unless validate_json(request.response[:response_body], req_num)
        next unless validate_resource_type(request, req_num)
        # skip test checking id
        next unless validate_resource_creation_time(request, req_num)
        next unless validate_resource_body(request.response[:request_body], request.response[:response_body], req_num)

        # check 2: validate the resource was created by performing a read request
        read_and_validate_resources(request.result_id)
      end
    end

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

    def validate_resource_creation_time(create_request, req_num)
      return if create_request.response[:created_at].present?

      add_message('error', no_time_created_message(create_request, req_num))
    end

    def validate_resource_body(create_request_body, create_response_body, req_num)
      return if create_request_body == create_response_body

      add_message('error', no_matching_json_message(create_request_body, create_response_body, req_num))
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

    def no_time_created_message(create_request, request_num = nil)
      prefix = request_num.present? ? "Request-#{request_num}: " : ''
      "#{prefix}Expected resource created to have creation time: `#{create_request.inspect}`"
    end

    def no_matching_json_message(create_request_body, create_response_body, request_num = nil)
      prefix = request_num.present? ? "Request-#{request_num}: " : ''
      "#{prefix}Expected resource to have request body: `#{create_request_body.inspect}`, but found " \
        "`#{create_response_body.inspect}`"
    end

    def no_error_validation(message)
      assert messages.none? { |msg| msg[:type] == 'error' }, message
    end

    def no_resource_created_message(received_resource_type, request_num = nil)
      prefix = request_num.present? ? "Request-#{request_num}: " : ''
      "#{prefix}Unable to create resource from unknown FHIR resource. Found type: `#{received_resource_type.inspect}`"
    end
  end
end
