require_relative 'version'

module PacioTestKit
  class Metadata < Inferno::TestKit
    id :pacio_test_kit
    title 'PACIO Test Kit'
    description <<~DESCRIPTION
      The PACIO Test Kit tests the conformance of server systems to the [PACIO Implementation Guides (IGs)](https://pacioproject.org).
      The tested IGs include:

      (List the tested IGs and link to the IG here)

      <!-- break -->

      ## Status

      These tests are a **DRAFT** intended to allow PACIO implementers to perform
      preliminary checks of their implementations against the tested IGs requirements and
      provide feedback on the tests. Future versions of these tests may validate additional PACIO IGs, other
      requirements and/or may change how these are tested.

      (Add additional details here)

      ## Test Scope and Limitations

      (Add Scope and Limitations here)
    DESCRIPTION
    suite_ids [:pacio_adi_server, :pacio_pfe_server, :pacio_rat_server, :pacio_toc_server]
    tags ['PACIO', 'PFE', 'ADI', 'RAT', "TOC"]
    last_updated LAST_UPDATED
    version VERSION
    maturity 'Low'
    authors ['Vanessa Fotso', 'Kaelyn Jefferson', 'Brian Meshell', 'Yunwei Wang']
    repo 'https://github.com/paciowg/pacio-test-kit'
  end
end
