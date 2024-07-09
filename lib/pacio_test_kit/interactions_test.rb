module PacioTestKit
  module InteractionsTest
    # TODO: All helper methods for interactions tests (CRUD) will be added here.
    def create_and_validate_resource(resource_to_create)
      fhir_resource = FHIR.from_contents(resource_to_create.to_json)
      assert(fhir_resource.present?, "The FHIR resource does not have a 'resourceType' field")
      assert_resource_type(resource_type, resource: fhir_resource)

      fhir_create(fhir_resource)
      assert_response_status(201)
      assert_valid_json(request.response_body, 'create response resource SHALL return a valid json')
      assert_resource_type(resource_type)
      validate_response_metadata(request.response_body, request.request_body, 'create')
      validate_create_response_headers(request.headers, resource_type, request.resource)
    end

    def validate_create_response_headers(headers, resource_type, response_resource)
      location_header = headers.find { |header| header.name.downcase == 'location' }
      assert(location_header.present?, 'Server SHALL create a Location header for the newly created resource.')

      location_header_value = location_header.value
      assert((location_header_value.include? resource_type) == true, 'Server SHALL create a location header with the resourceType of the newly created resource.')
      assert((location_header_value.include? response_resource.id) == true, 'Server SHALL create a location header with the id of the newly created resource.')
    end

    def read_and_validate_resources(resource_ids, tag = '')
      resource_ids = [resource_ids].flatten
      resource_ids.each_with_index do |id, index|
        req_num = index + 1
        fhir_read(resource_type, id, tags: [tag])

        status = request.response[:status]
        next unless validate_status('read', status, req_num)

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

    def validate_json(response_body, req_num = '')
      if valid_json?(response_body)
        true
      else
        add_message('error', "Request-#{req_num}: Response is not a valid JSON")
        false
      end
    end

    def validate_resource_type(resource, req_num = '')
      if resource.resourceType == resource_type
        true
      else
        add_message('error', wrong_resource_type_message(resource_type, req_num))
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

    def validate_response_metadata(response_resource, submitted_resource, method_type)
      if method_type == 'create'
        response = JSON.parse(response_resource)
        submitted = JSON.parse(submitted_resource)

        assert((response['id']).present?, 'Server SHALL populate the id for the newly created resource.')
        assert(response['id'] != submitted['id'], 'Server response resource and submitted resource SHALL have different ids for the newly created resource.')

        # if both blank, throw error; if both not blank, check if equal
        if response['meta']['versionId'].blank? && submitted['meta']['versionId'].blank?
          assert(!response['meta']['versionId'].blank? && !submitted['meta']['versionId'].blank?, 'Server response resource and submitted resource SHALL have different versionId fields for the newly created resource.')
        elsif !response['meta']['versionId'].blank? && !submitted['meta']['versionId'].blank?
          assert((response['meta']['versionId'] != submitted['meta']['versionId']), 'Server response resource and submitted resource SHALL have different versionId fields for the newly created resource.')
        end

        if response['meta']['lastUpdated'].blank? && submitted['meta']['lastUpdated'].blank?
          assert(!response['meta']['lastUpdated'].blank? && !submitted['meta']['lastUpdated'].blank?, 'Server response resource and submitted resource SHALL have different lastUpdated fields for the newly created resource.')
        elsif !response['meta']['lastUpdated'].blank? && !submitted['meta']['lastUpdated'].blank?
          assert(response['meta']['lastUpdated'] != submitted['meta']['lastUpdated'], 'Server response resource and submitted resource SHALL have different lastUpdated fields for the newly created resource.')
        end
      end
    end

    def bad_resource_id_message(expected_id, request_num = nil)
      prefix = request_num.present? ? "Request-#{request_num}: " : ''
      "#{prefix}Expected resource to have id `#{expected_id.inspect}`, but found `#{resource.id.inspect}`"
    end

    def wrong_resource_type_message(expected_resource_type, request_num = nil)
      prefix = request_num.present? ? "Request-#{request_num}: " : ''
      "#{prefix}Expected resource type to be: `#{expected_resource_type.inspect}`, but found " \
        "`#{resource.resourceType.inspect}`"
    end

    def no_error_validation(message)
      assert messages.none? { |msg| msg[:type] == 'error' }, message
    end
  end
end
