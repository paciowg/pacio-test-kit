# PACIO Test Kit

The PACIO Test Kit validates the conformance of systems to the following PACIO Implementation Guides:
* [PACIO Advance Healthcare Directive Interoperability IG v2.0.0-ballot](https://hl7.org/fhir/us/pacio-adi/2025Sep/)
* [PACIO Personal Functioning and Engagement IG v2.0.0](https://hl7.org/fhir/us/pacio-pfe/)
* [PACIO Re-Assessment Timepoints IG v1.0.0](https://hl7.org/fhir/us/pacio-rt/) (To Be Implemented)
* [PACIO Transition of Care IG v1.0.0-ballot](https://hl7.org/fhir/us/pacio-toc/2025May/) (To Be Impelemented)

This test kit currently contains suites that verify the conformation of system plyaing these following roles:
* **PACIO ADI Data Source and/or Server**: Verifies that the ADI Data Source and/or Server System can reponod to Data Consumer's requests of Creating, Reading, Searching, and Updating PACIO ADI FHIR resources.
* **PACIO PFE Data Source**: Verifies that the PFE Data Source System can reponod to Data Consumer's requests of Creating, Reading, Searching, and Updating PACIO ADI FHIR resources.

## Status

These tests are in low maturity, and intended to allow PACIO Implementation Guides implementers to performance prelimiary checks of their implementations against PACIO IGs' requirements and provide feedback on the tests. Future versions of these tests may validate other requirements and may change how these are tested.

## Known Limitation

This test kit does not currently include test suites for all actors and all capabilities defined by the each PACIO Implementation Guides.

## Getting Started

The quickest way to run this test kit locally is with [Docker](https://www.docker.com/).

* Install Docker
* Clone this [repository]((https://github.com/paciowg/pacio-test-kit)) from GitHub.
* Run `./setup.sh` within the test kit directory to download necessary dependencies
* Run `./run.sh` within the test kit directory to start the application
* Navigate to `http://localhost`
* Choose Test Suite to run and click "START TESTING" button
* (optional) Select a preset configuration from the "Preset" dropdown list from the top left corner.
* Click "RUN ALL TESTS" button on the top right corner
* Provide test configuration values in the pop-up dialog
* Click "SUMBIT" button at the bottom of the pop-up dialog
* Wait for the tests to complete.

See the [Inferno Documentation](https://inferno-framework.github.io/docs/getting-started-users.html#running-an-existing-test-kit) for more information on running Inferno locally.

## Interpret Test Results

Inferno test execution can result in several outcomes, with the four most common being **Pass**, **Fail**, **Skip**, and **Omit**. A quick FAQ explaining these outcomes can be found [here](https://github.com/onc-healthit/onc-certification-g10-test-kit/wiki/FAQ#q-what-is-the-difference-between-skipped-test-and-omitted-test).

## Repository and Resources

The PACIO Test Kit can be downloaded from its GitHub [repository](https://github.com/paciowg/pacio-test-kit).

## Providing Feedback and Reporting Issues

We welcome feedback on the tests, including but not limited to the following areas:
* Validation logic, such as potential bugs, lax checks, and unexpected failures.
* Requirements coverage, such as requirements that have been missed, tests that necessitate features that the IG does not require, or other issues with the interpretation of the IG’s requirements.
* User experience, such as confusing or missing information in the test UI.

Please report any issues with this set of tests in the [issues section](https://github.com/paciowg/pacio-test-kit/issues) of the repository.

## Inferno Documentation
- [Inferno documentation](https://inferno-framework.github.io/docs/)
- [Ruby API documentation](https://inferno-framework.github.io/inferno-core/docs/)
- [JSON API documentation](https://inferno-framework.github.io/inferno-core/api-docs/)

## License
Copyright 2024 TODO

Licensed under the Apache License, Version 2.0 (the "License"); you may not use
this file except in compliance with the License. You may obtain a copy of the
License at
```
http://www.apache.org/licenses/LICENSE-2.0
```
Unless required by applicable law or agreed to in writing, software distributed
under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
CONDITIONS OF ANY KIND, either express or implied. See the License for the
specific language governing permissions and limitations under the License.

## Trademark Notice

HL7, FHIR and the FHIR [FLAME DESIGN] are the registered trademarks of Health
Level Seven International and their use does not constitute endorsement by HL7.
