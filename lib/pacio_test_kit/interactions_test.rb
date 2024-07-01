module PacioTestKit
  module InteractionsTest
    # TODO: All helper methods for interactions tests (CRUD) will be added here.
    def create_and_validate_resources(resource_tocreate, _tag = '')
      resource_list = [resource_tocreate]
      [resource_list].each do
        resource_tocreate = JSON.parse(resource_tocreate)
        fhir_class_name = "FHIR::#{resource_type}"
        fhir_class_object = Object.const_get(fhir_class_name)
        fhir_resource = fhir_class_object.new(resource_tocreate)

        fhir_create(fhir_resource)

        next unless validate_status('create', request.response[:status])

        next unless validate_json(request.response_body)

        next unless validate_resource_type(resource)

        next unless validate_headers(request.response[:headers])

        validate_fields_updated(request.response)
      end
    end

    def validate_headers(headers, req_num = '')
      return false unless headers.present?

      headers.each_with_index do |_id, index|
        header = headers[index]
        header_hash = header.to_hash

        next unless header_hash[:name] == 'Location'
        return true if !header_hash[:id].nil? && !header_hash[:id][:_history][:vid].nil?

        status_error_msg = "Request-#{req_num}: Received Location but required headers (id, vid) not found, " \
                           "found #{header_hash}."
        add_message('error', status_error_msg)
        return false
      end
      status_error_msg = "Request-#{req_num}: Expected Location and required headers (id, vid) not found, " \
                         "found #{headers}."
      add_message('error', status_error_msg)

      false
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

    def validate_status(method_type, status, req_num = '')
      if method_type == 'read'
        passing_num = 200
      elsif method_type == 'create'
        passing_num = 201
      end

      if status == passing_num
        true
      else
        status_error_msg = "Request-#{req_num}: Unexpected response status: expected #{passing_num}, " \
                           "but received #{status}"
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

    def validate_fields_updated(response)
      prepost_id = 'PFEIG-CSC-Hospital-MMSE-1-Ob-Question-31'
      postpost_id = response[:id].present? ? response[:id] : ''
      pre_versionid = ''
      post_versionid = response[:meta].present? ? response[:meta].versionId : ''
      pre_lastupdated = ''
      post_lastupdated = response[:meta].present? ? response[:meta].lastUpdated : ''

      if (prepost_id != postpost_id) && (pre_versionid != post_versionid) && (pre_lastupdated != post_lastupdated)
        return true
      end

      missing_response_fields(postpost_id, post_versionid, post_lastupdated)
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

    def missing_response_fields(response_id, meta_versionid, meta_lastupdated, request_num = nil)
      prefix = request_num.present? ? "Request-#{request_num}: " : ''
      "#{prefix}Expected resource to have id, meta.versionId, and meta.lastUpdated, but found `#{response_id}`, " \
        "`#{meta_versionid}` and, `#{meta_lastupdated}`"
    end
  end
end
