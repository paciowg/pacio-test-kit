module PacioTestKit
  module InteractionsTest
    # TODO: All helper methods for interactions tests (CRUD) will be added here.
    def create_and_validate_resources(resource, tag = '')

      # make FHIR resource object
      new_resource = new Object.const_get(resource_type)

      # send object to create on server
      fhir_create(new_resource)

      # validate the resource from the request.response
      status = request.response[:status]
      headers = request.response[:headers]

      # create SHALL return status and headers
      validate_status("create", status, req_num)
      validate_headers(headers, req_num)
      
    end

    def validate_headers(headers, req_num)
      headers.each_with_index do |id, index|
        
        if headers[i][:name] == "Location"
          location_id = headers[i][:id]
          location_vid =  headers[i][:id][:_history][:vid]
        
          # create response shall contain location header (id, vid)
          return if location_id.present? && location_vid.present?
          
          status_error_msg = "Request-#{req_num}: Expected Location header: id or vid not found."
          add_message('error', status_error_msg)


    def read_and_validate_resources(resource_ids, tag = '')
      resource_ids = [resource_ids].flatten
      resource_ids.each_with_index do |id, index|
        req_num = index + 1
        fhir_read(resource_type, id, tags: [tag])

        status = request.response[:status]
        next unless validate_status("read", status, req_num)

        next unless validate_json(request.response_body, req_num)

        next unless validate_resource_type(resource, req_num)

        validate_resource_id(resource, id, req_num)
      end
    end

    def validate_status(method_type, status, req_num)

      if method_type == "read"
        passing_num = 200
      elsif method_type == "create"
        passing_num = 201
      
      if status == passing_num
        true
      else
        status_error_msg = "Request-#{req_num}: Unexpected response status:#{passing_num} expected, but received #{status}"
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
