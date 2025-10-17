# PACIO Test Kit

The PACIO Test Kit validates the conformance of systems to the following PACIO Implementation Guides:

* [PACIO Advance Healthcare Directive Interoperability IG v2.0.0-ballot](https://hl7.org/fhir/us/pacio-adi/2025Sep/)
* [PACIO Personal Functioning and Engagement IG v2.0.0](https://hl7.org/fhir/us/pacio-pfe/)
* [PACIO Transition of Care IG v1.0.0-ballot](https://hl7.org/fhir/us/pacio-toc/2025May/)
* [PACIO Standardized Medication Profile IG v1.0.0](https://hl7.org/fhir/us/smp/)

This test kit currently contains suites that verify the **conformance** of systems playing the following roles:

* **PACIO ADI Data Source and/or Server**: Verifies that the ADI Data Source and/or Server system can respond to Data Consumer requests for creating, reading, searching, and updating PACIO ADI FHIR resources.
* **PACIO PFE Data Source**: Verifies that the PFE Data Source system can respond to Data Consumer requests for creating, reading, searching, and updating PACIO PFE FHIR resources.
* **PACIO TOC Server**: Verifies that the TOC Server can respond to client requests for creating, reading, searching, and updating PACIO TOC FHIR resources.

## Status

These tests are in early development and are intended to allow PACIO Implementation Guide implementers to perform preliminary checks of their implementations against PACIO IG requirements and to provide feedback. Future versions of these tests may validate additional requirements and may change how validation is performed.

## Known Limitations

This test kit does not currently include test suites for all actors and all capabilities defined by each PACIO Implementation Guide.

## Getting Started

The quickest way to run this test kit locally is with [Docker](https://www.docker.com/).

1. Install Docker
2. Clone this [repository](https://github.com/paciowg/pacio-test-kit) from GitHub.
3. Run `./setup.sh` within the test kit directory to download necessary dependencies.
4. Run `./run.sh` within the test kit directory to start the application.
5. Open a web browser and navigate to `http://localhost`.
6. Choose a Test Suite to run and click the **START TESTING** button.
7. (Optional) Select a preset configuration from the **Preset** dropdown list in the top-left corner.
8. Click the **RUN ALL TESTS** button in the top-right corner.
9. Provide test configuration values in the pop-up dialog.
10. Click the **SUBMIT** button at the bottom of the dialog.
11. Wait for the tests to complete.

See the [Inferno Documentation](https://inferno-framework.github.io/docs/getting-started-users.html#running-an-existing-test-kit) for more information on running Inferno locally.

See the [TOC Instructions](/lib/pacio_test_kit/toc/TOC_INSTRUCTIONS.md) for step-by-step instructions for how to use the PACIO TOC Server Suite

## Interpreting Test Results

Inferno test execution can result in several outcomes, with the four most common being **Pass**, **Fail**, **Skip**, and **Omit**. A quick FAQ explaining these outcomes can be found [here](https://github.com/onc-healthit/onc-certification-g10-test-kit/wiki/FAQ#q-what-is-the-difference-between-skipped-test-and-omitted-test).

## Repository and Resources

The PACIO Test Kit can be downloaded from its GitHub [repository](https://github.com/paciowg/pacio-test-kit).

## Providing Feedback and Reporting Issues

We welcome feedback on the tests, including but not limited to the following areas:

* **Validation logic** — potential bugs, overly lax checks, or unexpected failures.
* **Requirements coverage** — requirements that may have been missed, tests that demand features not required by the IG, or other issues with the interpretation of IG requirements.
* **User experience** — confusing or missing information in the test UI.

Please report any issues with this test kit in the [Issues section](https://github.com/paciowg/pacio-test-kit/issues) of the repository.

## Inferno Documentation

- [Inferno documentation](https://inferno-framework.github.io/docs/)
- [Ruby API documentation](https://inferno-framework.github.io/inferno-core/docs/)
- [JSON API documentation](https://inferno-framework.github.io/inferno-core/api-docs/)

## License

Copyright 2024 TODO

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
You may obtain a copy of the License at:
```
http://www.apache.org/licenses/LICENSE-2.0
```

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an **“AS IS” BASIS**, without warranties or conditions of any kind, either express or implied. See the License for the specific language governing permissions and limitations under the License.

## Trademark Notice

HL7, FHIR, and the FHIR [FLAME DESIGN] are registered trademarks of Health Level Seven International, and their use does not constitute endorsement by HL7.

