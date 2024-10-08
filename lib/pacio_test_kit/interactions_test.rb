module PacioTestKit
  module InteractionsTest
    def update_and_validate_resource(resource_to_update)
      statuses = ['final', 'cancelled']
      new_status = statuses.find { |status| status != resource_to_update.status }
      resource_to_update.status = new_status

      fhir_update(resource_to_update, resource_to_update.id)
      perform_update_validation(resource_to_update)
    end

    def perform_update_validation(resource_to_update)
      assert_response_status(200)

      assert_resource_type(resource_type)

      msg = "Update must not change the resource ID: expected ID `#{resource_to_update.id}`, got `#{resource.id}`"
      assert(resource_to_update.id == resource.id, msg)

      msg = "Update failed: Expected status to be updated to `#{resource_to_update.status}`, got `#{resource.status}`"
      assert(resource.status == resource_to_update.status, msg)

      validate_response_metadata(resource, resource_to_update, 'update')
    end

    def create_and_validate_resource(resource_to_create)
      fhir_resource = validate_resource_input(resource_to_create)

      fhir_create(fhir_resource.deep_dup)

      assert_response_status(201)
      assert_valid_json(request.response_body, 'create interaction response must be a valid JSON')
      assert_resource_type(resource_type)
      validate_response_metadata(resource, fhir_resource, 'create')
      validate_create_response_headers(request.headers, resource)
    end

    def validate_resource_input(resource_to_create)
      fhir_resource = FHIR.from_contents(resource_to_create.to_json)
      skip_if fhir_resource.blank?, 'resource input submitted does not have a `resourceType` field'
      skip_if resource_type != fhir_resource.resourceType, 'Unexpected resource type: expected ' \
                                                           "#{resource_type}, received #{fhir_resource.resourceType}"
      fhir_resource
    end

    def validate_create_response_headers(headers, response_resource)
      location_header = headers.find { |header| header.name.downcase == 'location' }
      assert(location_header.present?, 'Server SHALL return a Location header.')

      relative_path = "#{response_resource.resourceType}/#{response_resource.id}"

      location_header_value = location_header.value
      error_message = 'The location header is incorrectly formatted. Expected patterns:' \
                      'server_base_url/resource_type/resource_id/_history/version_id, resource_type/' \
                      'resource_id/_history/version_id, or resource_type/resource_id.'
      assert(location_header_value.include?(relative_path), error_message)
    end

    def read_and_validate_resources(resource_ids, tag = '')
      resource_ids = [resource_ids].flatten
      resource_ids.each_with_index do |id, index|
        req_num = index + 1
        fhir_read(resource_type, id, tags: [tag])

        status = request.response[:status]
        next unless validate_status(200, status, req_num)

        next unless validate_json(request.response_body, req_num)

        next unless validate_resource_type(resource, req_num)

        validate_resource_id(resource, id, req_num)
      end
    end

    def validate_status(expected_status, received_status, req_num = '')
      if expected_status == received_status
        true
      else
        prefix = req_num.present? ? "Request-#{req_num}: " : ''
        status_error_msg = "#{prefix}Unexpected response status: expected #{expected_status}, " \
                           "but received #{received_status}"
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
      if response_resource.id.present?
        error_message = 'Server SHALL ignore `id` provided in the request body.'
        add_message('error', error_message) if method_type == 'create' && response_resource.id == submitted_resource.id
      else
        add_message('error', 'Server SHALL populate the `id` for the newly created resource')
      end

      validate_meta_field(response_resource, submitted_resource, 'lastUpdated')
      validate_meta_field(response_resource, submitted_resource, 'versionId') if method_type != 'create'
    end

    def validate_meta_field(response_resource, submitted_resource, field)
      if response_resource.meta&.send(field).present? &&
         response_resource.meta.send(field) == submitted_resource.meta&.send(field)
        add_message('error', "Server SHALL ignore `meta.#{field}` provided in the request body.")
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
