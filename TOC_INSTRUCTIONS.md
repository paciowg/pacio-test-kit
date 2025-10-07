# Step-by-Step Instructions for Using the PACIO TOC Server Suite

Users can start by selecting the "RUN ALL TESTS" button in the upper right. This
will bring up a form with a number of inputs that need to be filled out to run
all test groups in the test suite. Alternatively, users can run each group one
at a time by selecting them and then clicking the "RUN TESTS" button, in which
case the form will be limited to the inputs necessary to run that group. The
test groups can be run in any order.

Below is a list of all of the inputs for the Test Suite, grouped by Test Group,
along with explanation and guidance for filling them out.

## All test groups

There is one input which is needed for all test groups:

1. **FHIR Server Base URL (required)**: Used by all test groups. This is
the base URL that Inferno will use to construct all FHIR requests. For example,
if the base URL is `https://example.com/fhir/r4`, then a Patient request will
go to `https://example.com/fhir/r4/Patient/123`.

## TOC Bundle Tests

1. **Bundle resource to create on the server. (required)**: Used by the TOC
Bundle Tests group. The input should be a TOC FHIR Bundle in JSON format. The
[expected structure](https://hl7.org/fhir/us/pacio-toc/2025May/guidance.html#transitions-of-care-document-structure)
of this Bundle is defined in the implementation guide. The implementation guide
also contains an
[example in JSON format](https://hl7.org/fhir/us/pacio-toc/2025May/Bundle-Example-Smith-Johnson-Bundle.json.html).
Inferno will take the Bundle provided and create it with an HTTP POST request
on the server under test.
1. **ID(s) for Bundle resources present on the server (optional)**: Used by the
TOC Bundle Tests group. The input should be a comma separated list of IDs for
any TOC Bundles already on the server that should be included in the tests. For
example, if a Bundle the user wants to test is at the URL
`https://example.com/fhir/r4/Bundle/234`, they should enter `234` into the
input.

## TOC Composition Tests

1. **TOC Composition resource to create on the server. (required)**: Used by the
TOC Composition Tests group. The input should be an instance of a TOC
Composition resource in JSON format. There is a
[profile](https://hl7.org/fhir/us/pacio-toc/2025May/StructureDefinition-TOC-Composition.html)
for this resource in the implementation guide which includes an
[example in JSON format](https://hl7.org/fhir/us/pacio-toc/2025May/Composition-BSJ-TOCComposition.json.html).
Inferno will take the Composition provided and create it with an HTTP POST request
on the server under test.
1. **ID(s) for TOC Composition resources present on the server (optional)**:
Used by the TOC Composition Tests group. The input should be a comma separated
list of IDs for any other TOC Compositions already on the server that the user
wishes to include in the tests, if any. For example, if the user wants to
include a Composition at the URL `https://example.com/fhir/r4/Composition/345`,
they should enter `345` into the input.

## Organization Tests

1. **Organization resource to create on the server (required)**: Used by the
Organization Tests group. The input should be an instance of a US Core
Organization resource in JSON format. There is a
[profile](http://hl7.org/fhir/us/core/STU6.1/StructureDefinition-us-core-organization.html)
for this resource in the US Core implementation guide which includes
[several examples](http://hl7.org/fhir/us/core/STU6.1/StructureDefinition-us-core-organization-examples.html).
Inferno will take the Organization provided and create it with an HTTP POST request
on the server under test.
1. **ID(s) for a given profile resources present on the server**: Used by the
Organization Tests group. The input should be a comma separated
list of IDs for any other Organizations already on the server that the user
wishes to include in the tests, if any. For example, if the user wants to
include an Organization at the URL
`https://example.com/fhir/r4/Organization/456`, they should enter `456` into the
input.

## Patient Tests

1. **Patient resource to create on the server (required)**: Used by the Patient
Tests group. The input should be an instance of a US Core
Patient resource in JSON format. There is a
[profile](http://hl7.org/fhir/us/core/STU6.1/StructureDefinition-us-core-patient.html)
for this resource in the US Core implementation guide which includes
[several examples](http://hl7.org/fhir/us/core/STU6.1/StructureDefinition-us-core-patient-examples.html).
Inferno will take the Patient provided and create it with an HTTP POST request
on the server under test.
1. **ID(s) for TOC Patient resources present on the server**: Used by the
Patient Tests group. The input should be a comma separated list of IDs for any
other Patients already on the server that the user wishes to test, if any. For
example, if the user wants to include a Patient at the URL
`https://example.com/fhir/r4/Patient/567`, they should enter `567` into the
input.

## Error Handling Tests

1. **Search Method**: Used by the Error Handling Tests group. This allows the
user to choose whether Inferno should use GET or POST requests when making
search requests to the server under test. Inferno will default to GET, but
either method is allowed in FHIR.
1. **ID for a deleted resource from the server for deleted resource error testing (required)**:
Used by the Error Handling Tests group. Prior to running this test group, the
user must either delete a resource instance from the server under test or
identify an already-deleted instance. This input is for the ID of that instance.
For example, if the deleted instance is
`https://example.com/fhir/r4/Organization/678`, the user would enter `678`.
1. **Resource type for the deleted resource from the server for deleted resource error testing (required)**:
Used by the Error Handling Tests group. This input is for the resource type of
the already-deleted FHIR resource instance described above. For example, if the
deleted resource is `https://example.com/fhir/r4/Organization/678`, the
user would enter `Organization`. It can be any resource type.
1. **ID of an existing patient resource to retrieve for unauthorized request testing (required)**:
Used by the Error Handling Tests group. Prior to running this test group, the
user must either create or identify a Patient on the server under test which
Inferno is not authorized to access and input the ID. For example, if the
Patient is `https://example.com/fhir/r4/Patient/789`, the user would enter
`789`.