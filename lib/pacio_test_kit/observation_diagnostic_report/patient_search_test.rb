module PacioTestKit
  class PatientSearchTypeTest < Inferno::Test
    title 'Resource can be found with search-type interaction by patient'
    id :pacio_patient_search_type
    description 'A server SHALL support the search-type interaction.'

    def resource_type
      config.options[:resource_type]
    end

    def tag
      config.options[:profile]
    end

    run do
      # TODO
    end
  end
end
