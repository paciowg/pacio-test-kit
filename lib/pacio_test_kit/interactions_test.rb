module PacioTestKit
  module InteractionsTest
    # TODO: All helper methods for interactions tests (CRUD) will be added here.

    def read_and_validate_resources(resource_ids, tag = '')
      resource_ids = [resource_ids].flatten
      resource_ids.each do |id|
        fhir_read(resource_type, id, tags: [tag])
      end

      requests.each_with_index do |request, index|
        req_num = index + 1
        status = request.response[:status]
        status_error_msg = "Request-#{req_num}: Unexpected response status: expected 200, but received #{status}"
        add_message('error', status_error_msg) unless status == 200
        next if valid_json?(request.response_body)

        add_message('error', "Request-#{req_num}: Response is not a valid JSON")
      end
    end

    def valid_json?(json)
      JSON.parse(json)
      true
    rescue JSON::ParserError
      false
    end

    def no_error_validation(message)
      assert messages.none? { |msg| msg[:type] == 'error' }, message
    end
  end
end
