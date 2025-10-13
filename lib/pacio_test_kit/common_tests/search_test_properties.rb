module PacioTestKit
  class SearchTestProperties
    ATTRIBUTES = [
      :resource_type,
      :search_params,
      :token_search_params,
      :test_post_search,
      :test_reference_variants
    ].freeze

    ATTRIBUTES.each { |name| attr_reader name }

    def initialize(**properties)
      properties.each do |key, value|
        raise StandardError, "Unkown search test property: #{key}" unless ATTRIBUTES.include?(key)

        value = value.map { |v| SearchParam.new(**v) } if [:search_params, :token_search_params].include?(key)
        instance_variable_set(:"@#{key}", value)
      end
    end

    def test_post_search?
      !!test_post_search
    end

    def token_search_params?
      token_search_params.present?
    end

    def test_reference_variants?
      !!test_reference_variants
    end
  end

  class SearchParam
    attr_reader :name, :paths

    def initialize(name:, paths:)
      @name = name
      @paths = paths
    end
  end
end
