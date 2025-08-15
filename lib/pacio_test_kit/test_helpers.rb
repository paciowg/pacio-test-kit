module PacioTestKit
  module TestHelpers
    def no_error_validation(message)
      assert messages.none? { |msg| msg[:type] == 'error' }, message
    end

    def extract_target_resources(resources, resource_type)
      bundle_resources = resources
        .select { |r| r.resourceType == 'Bundle' }
        .flat_map { |b| b.entry.map(&:resource) }
        .compact

      all_resources = (resources + bundle_resources).uniq
      all_resources.select { |r| r.resourceType == resource_type }
    end
  end
end
