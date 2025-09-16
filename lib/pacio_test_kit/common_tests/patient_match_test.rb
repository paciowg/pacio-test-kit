module PacioTestKit
  class PatientMatchTest < Inferno::Test
    title 'Server returns valid results for patient $match operation'
    description %(
      A server SHALL support patient $match operation.

      This test will pass if Patient resources are returned and match the Patient resource provided. If
      none are returned, the test is skipped.
    )

    id :patient_match_test

    def resource_type
      config.options[:resource_type]
    end

    def tag
      config.options[:profile]
    end

    def read_resources
      @read_resources ||= begin
        read_requests = load_tagged_requests(tag)
        skip_if read_requests.blank?, "No #{tag} resource read request was made in previous tests."
        successful_requests = read_requests.select { |req| req.status == 200 }
        skip_if successful_requests.empty?, "All #{tag} resource read requests failed."
        successful_requests.map(&:resource).uniq.compact
      end
    end

    def check_match_response
      assert_response_status(200)
      assert_valid_json(request.response_body)
      assert_resource_type(:bundle)
    end

    def verify_match_result(input_patient)
      all_resources = fetch_all_bundled_resources(resource_type:)
      assert all_resources.any?, 'Patient $match operation does not return any Patient resource.'

      input_identifier = input_patient.identifier.first

      first_unmatched = all_resources.find do |resource|
        resource.identifier&.none? do |identifier|
          identifier.system == input_identifier.system && identifier.value == input_identifier.value
        end
      end

      assert first_unmatched.nil?, "Patient #{first_unmatched&.id} returned from $match operation does not have " \
                                   "matched identifier value #{input_identifier.system}##{input_identifier.value}."
    end

    run do
      skip_if read_resources.blank?, "No #{tag} resources returned from previous read request."
      input_resource = FHIR::Patient.new(
        identifier: [
          read_resources.first.identifier.first
        ]
      )

      body = FHIR::Parameters.new(
        parameter: [
          {
            name: 'resource',
            resource: input_resource
          },
          {
            name: 'count',
            valueInteger: 20
          }
        ]
      )

      fhir_operation('Patient/$match', body:, tags: ["#{tag}_match"])
      check_match_response
      verify_match_result(input_resource)
    end
  end
end
