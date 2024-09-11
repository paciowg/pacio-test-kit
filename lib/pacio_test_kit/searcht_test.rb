require_relative 'date_search_validation'
require_relative 'search_test_properties'

module PacioTestKit
  module SearchTest
    extend Forwardable
    include DateSearchValidation

    def_delegators 'self.class', :properties
    def_delegators 'properties',
                   :resource_type,
                   :search_params,
                   :token_search_params,
                   :test_post_search?,
                   :token_search_params?,
                   :test_reference_variants?

    def read_resources
      @read_resources ||= begin
        load_tagged_requests(tag)
        skip_if requests.blank?, "No #{tag} resource read or search request was made in previous tests."
        successful_requests = requests.select { |req| req.status == 200 }
        skip_if successful_requests.empty?, "All #{tag} resource read or search requests failed."
        successful_requests.map(&:resource).uniq.compact
      end
    end

    def valid_search_params?(params)
      params&.all? { |_name, value| value.present? }
    end

    def run_search_test
      params = search_params_with_values
      skip_if !valid_search_params?(params), unable_to_resolve_params_message(search_params.map(&:name))

      target_resources = perform_search(params)
      skip_if target_resources.empty?, no_resources_skip_message
    end

    def perform_search(params)
      search_and_check_response(params)
      target_resources = fetch_filtered_resources

      return [] if target_resources.blank?

      check_all_resources_against_params(target_resources, params)

      perform_post_search(target_resources, params) if test_post_search?
      perform_reference_with_type_search(params, target_resources.count) if test_reference_variants?
      perform_search_with_system(params) if token_search_params?

      target_resources
    end

    def fetch_filtered_resources
      fetch_all_bundled_resources.select { |res| res.resourceType == resource_type }
    end

    def perform_post_search(get_search_resources, params)
      fhir_search resource_type, params:, search_method: :post
      check_search_response

      post_search_resources = fetch_filtered_resources

      get_resource_count = get_search_resources.length
      post_resource_count = post_search_resources.length

      assert get_resource_count == post_resource_count,
             'Expected POST search to return the same results as GET, but found ' \
             "#{get_resource_count} resources for GET and #{post_resource_count} for POST."
    end

    def perform_reference_with_type_search(params, resource_count)
      return if resource_count.zero?

      new_search_params = params.merge('patient' => get_new_patient_search_value(params))
      search_and_check_response(new_search_params)

      new_resource_count = fetch_filtered_resources.size

      assert new_resource_count == resource_count,
             "Expected search by `#{params['patient']}` to return the same results as searching " \
             "by `#{new_search_params['patient']}`, but found #{resource_count} resources with " \
             "`#{params['patient']}` and #{new_resource_count} with `#{new_search_params['patient']}`"
    end

    def perform_search_with_system(params)
      new_search_params = search_params_with_values(token_search_params, include_system: true)
      return unless valid_search_params?(new_search_params)

      merged_params = params.merge(new_search_params)
      search_and_check_response(merged_params)

      assert fetch_filtered_resources.present?, 'No resources found with system|code search.'
    end

    def search_and_check_response(params, resource_type = self.resource_type)
      fhir_search resource_type, params:, tags: ["#{tag}_Search"]

      check_search_response
    end

    def check_search_response
      assert_response_status(200)
      assert_resource_type(:bundle)
    end

    def fetch_all_bundled_resources(
      reply_handler: nil,
      max_pages: 20,
      additional_resource_types: [],
      resource_type: self.resource_type
    )
      resources = []
      page_count = 1
      bundle = resource

      until end_of_pagination?(bundle, page_count, max_pages)
        resources.concat(bundle&.entry&.map(&:resource))
        next_bundle_link = find_next_bundle_link(bundle)
        reply_handler&.call(response)

        break if next_bundle_link.blank?

        bundle = fetch_next_bundle(next_bundle_link)

        page_count += 1
      end

      check_resource_types(resources, resource_type, additional_resource_types)

      resources
    end

    def find_next_bundle_link(bundle)
      bundle&.link&.find { |link| link.relation == 'next' }&.url
    end

    def end_of_pagination?(bundle, page_count, max_pages)
      bundle.nil? || page_count >= max_pages
    end

    def fetch_next_bundle(next_bundle_link)
      reply = fhir_client.raw_read_url(next_bundle_link)

      store_request('outgoing', tags: ["#{tag}_Search"]) { reply }

      assert_response_status(200)
      assert_valid_json(reply.body, cant_resolve_next_bundle_message(next_bundle_link))

      fhir_client.parse_reply(FHIR::Bundle, fhir_client.default_format, reply)
    end

    def check_resource_types(resources, resource_type, additional_resource_types)
      valid_resource_types = [resource_type, 'OperationOutcome'] + additional_resource_types

      invalid_resource_types = resources.reject do |entry|
        valid_resource_types.include?(entry.resourceType)
      end.map(&:resourceType).uniq

      return unless invalid_resource_types.any?

      info "Received resource type(s) #{invalid_resource_types.join(', ')} in search bundle, " \
           "but only expected resource types #{valid_resource_types.join(', ')}. " \
           'This is unusual but allowed if the server believes additional resource types are relevant.'
    end

    def search_params_with_values(params = search_params, include_system: false)
      resources = read_resources
      return if resources.blank?

      resources.each_with_object({}) do |resource, outer_params|
        results_from_one_resource = params.each_with_object({}) do |search_param, inner_params|
          inner_params[search_param.name] = search_param_value(resource, search_param.paths, include_system:)
        end

        outer_params.merge!(results_from_one_resource)

        return outer_params if outer_params.all? { |_key, value| value.present? }
      end
    end

    def search_param_value(resource, paths, include_system: false)
      search_value = nil
      paths.each do |path|
        element = fhir_path_single_result(resource, path)&.dig('element')
        next unless element.present?

        search_value = extract_search_value(element, path, resource, include_system)
        break if search_value.present?
      end

      search_value
    end

    def extract_search_value(element, path, resource, include_system) # rubocop:disable Metrics/CyclomaticComplexity
      case element
      when FHIR::Period
        extract_period_value(element)
      when FHIR::Reference
        element.reference
      when FHIR::CodeableConcept
        extract_codeable_concept_value(resource, path, include_system)
      when FHIR::Identifier
        extract_identifier_value(element, include_system)
      when FHIR::Coding
        extract_coding_value(element, include_system)
      when FHIR::HumanName
        extract_human_name_value(element)
      when FHIR::Address
        extract_address_value(element)
      else
        element
      end
    end

    def extract_period_value(element)
      if element.start.present?
        "gt#{(DateTime.xmlschema(element.start) - 1).xmlschema}"
      else
        end_datetime = get_fhir_datetime_range(element.end)[:end]
        "lt#{(end_datetime + 1).xmlschema}"
      end
    end

    def extract_codeable_concept_value(resource, path, include_system)
      if include_system
        coding = fhir_path_single_result(resource, "#{path}.coding") do |c|
          c.code.present? && c.system.present?
        end&.dig('element')
        "#{coding.system}|#{coding.code}" if coding
      else
        fhir_path_single_result(resource, "#{path}.coding.code")&.dig('element')
      end
    end

    def extract_identifier_value(element, include_system)
      include_system ? "#{element.system}|#{element.value}" : element.value
    end

    def extract_coding_value(element, include_system)
      include_system ? "#{element.system}|#{element.code}" : element.code
    end

    def extract_human_name_value(element)
      element.family || element.given&.first || element.text
    end

    def extract_address_value(element)
      element.text || element.city || element.state || element.postalCode || element.country
    end

    def fhir_path_single_result(resource, path, &)
      results = evaluate_fhirpath(resource, path)
      return unless results.present?

      return results.first unless block_given?

      element = results.map { |result| result['element'] }.find(&)
      results.find { |result| result['element'] == element }
    end

    def evaluate_fhirpath(resource, path)
      fhirpath_url = ENV.fetch('FHIRPATH_URL')
      endpoint = "#{fhirpath_url}/evaluate?path=#{path}"
      logger = Logger.new($stdout)
      response = Faraday.post(endpoint, resource.to_json, 'Content-Type' => 'application/json')
      return unless response.status.to_s.start_with?('2')

      transform_fhirpath_results(JSON.parse(response.body))
    rescue Faraday::Error => e
      logger.error "FHIRPath service not available: #{e.message}"
    rescue JSON::ParserError
      logger.error "Error parsing response from FHIRPath service: response body\n #{response.body}"
    end

    def transform_fhirpath_results(fhirpath_results)
      fhirpath_results.each do |result|
        klass = Object.const_get("FHIR::#{result['type']}")
        result['element'] = klass.new(result['element'])
      rescue NameError
        next
      end
      fhirpath_results
    end

    def get_new_patient_search_value(params)
      params['patient'].include?('/') ? params['patient'].split('/').last : "Patient/#{params['patient']}"
    end

    def cant_resolve_next_bundle_message(link)
      "Could not resolve next bundle: #{link}"
    end

    def no_resources_skip_message(resource_type = self.resource_type)
      "No #{resource_type} resources appear to be available. Please provide id for resource with more information."
    end

    def unable_to_resolve_params_message(search_param_names)
      "Could not find values for all search params #{search_param_names.to_sentence}"
    end

    #### RESULT CHECKING ####

    def check_all_resources_against_params(resources, params)
      resources.each do |resource|
        check_resource_against_params(resource, params)
      end
    end

    def check_resource_against_params(resource, params)
      params.each do |name, escaped_search_value|
        values_found = []
        search_value = unescape_search_value(escaped_search_value)

        assert resource_matches_param?(resource, name, search_value, values_found),
               "#{resource_type}/#{resource.id} did not match the search parameters:\n" \
               "* Expected: #{search_value}\n" \
               "* Found: #{values_found.map(&:inspect).join(', ')}"
      end
    end

    def unescape_search_value(value)
      value&.gsub('\\,', ',')
    end

    def resource_matches_param?(resource, search_param_name, search_value, values_found = [])
      search_value = unescape_search_value(search_value)
      paths = search_param_paths(search_param_name)

      paths.each do |path|
        results = evaluate_fhirpath(resource, path)
        next unless results.present?

        type = results.first['type']
        values_found.concat(extract_values_from_results(results, type))

        return true if match_found?(type, search_value, values_found, search_param_name)
      end

      false
    end

    def extract_values_from_results(results, type)
      results.map do |result|
        type == 'Reference' ? result['element'].reference : result['element']
      end
    end

    def match_found?(type, search_value, values_found, search_param_name) # rubocop:disable Metrics/CyclomaticComplexity
      case type
      when 'Period', 'date', 'instant', 'dateTime'
        values_found.any? { |date| validate_date_search(search_value, date) }
      when 'HumanName'
        match_human_name?(search_value, values_found)
      when 'Address'
        match_address?(search_value, values_found)
      when 'CodeableConcept'
        match_codeable_concept?(search_value, values_found)
      when 'Coding'
        match_coding?(search_value, values_found)
      when 'Identifier'
        match_identifier?(search_value, values_found)
      when 'string'
        match_string?(search_value, values_found)
      else
        match_special_cases?(search_value, values_found, search_param_name)
      end
    end

    def match_human_name?(search_value, values_found) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity
      search_value_downcase = search_value.downcase
      values_found.any? do |name|
        name&.text&.downcase&.start_with?(search_value_downcase) ||
          name&.family&.downcase&.start_with?(search_value_downcase) ||
          name&.given&.any? { |given| given.downcase.start_with?(search_value_downcase) } ||
          name&.prefix&.any? { |prefix| prefix.downcase.start_with?(search_value_downcase) } ||
          name&.suffix&.any? { |suffix| suffix.downcase.start_with?(search_value_downcase) }
      end
    end

    def match_address?(search_value, values_found) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity
      search_value_downcase = search_value.downcase
      values_found.any? do |address|
        address&.text&.downcase&.start_with?(search_value_downcase) ||
          address&.city&.downcase&.start_with?(search_value_downcase) ||
          address&.state&.downcase&.start_with?(search_value_downcase) ||
          address&.postalCode&.downcase&.start_with?(search_value_downcase) ||
          address&.country&.downcase&.start_with?(search_value_downcase)
      end
    end

    def match_codeable_concept?(search_value, values_found) # rubocop:disable Metrics/CyclomaticComplexity
      codings = values_found.flat_map(&:coding)
      if search_value.include?('|')
        system, code = search_value.split('|')
        codings.any? { |coding| coding.system == system && coding.code&.casecmp?(code) }
      else
        codings.any? { |coding| coding.code&.casecmp?(search_value) }
      end
    end

    def match_coding?(search_value, values_found)
      if search_value.include?('|')
        system, code = search_value.split('|')
        values_found.any? { |coding| coding.system == system && coding.code&.casecmp?(code) }
      else
        values_found.any? { |coding| coding.code&.casecmp?(search_value) }
      end
    end

    def match_identifier?(search_value, values_found)
      if search_value.include?('|')
        values_found.any? { |identifier| "#{identifier.system}|#{identifier.value}" == search_value }
      else
        values_found.any? { |identifier| identifier.value == search_value }
      end
    end

    def match_string?(search_value, values_found)
      searched_values = search_value.downcase.split(/(?<!\\\\),/).map { |string| string.gsub('\\,', ',') }
      values_found.any? do |value_found|
        searched_values.any? { |searched_value| value_found.downcase.starts_with?(searched_value) }
      end
    end

    def match_special_cases?(search_value, values_found, search_param_name)
      if %w[subject patient].include?(search_param_name.to_s)
        id = search_value.split('Patient/').last
        possible_values = [id, "Patient/#{id}", "#{url}/Patient/#{id}"]
        values_found.any? { |reference| possible_values.include?(reference) }
      else
        search_values = search_value.split(/(?<!\\\\),/).map { |string| string.gsub('\\,', ',') }
        values_found.any? { |value_found| search_values.include?(value_found) }
      end
    end

    def search_param_paths(search_param_name)
      search_params.find { |param| param.name == search_param_name }.paths
    end
  end
end
