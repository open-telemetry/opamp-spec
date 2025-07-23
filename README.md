# OpAMP Specification

This repository contains Open Agent Management Protocol (OpAMP)
[specification](specification.md) and Protobuf definitions in [proto](proto) directory.

See [releases here](https://github.com/open-telemetry/opamp-spec/releases) and [changelog here](CHANGELOG.md).

## Contributing

Prerequisites:
- [NodeJS/NPM CLI](https://nodejs.org/en/download/)

The specification is a [single markdown file](specification.md). If you make changes to
the section headings make sure to update the Table of Contents by running
`make markdown-toc` in root directory.

If any changes are made to Protobuf message definitions in the specification.md make
sure to update also the `*.proto` files in the [proto](proto) directory. Run `make gen-proto`
to run the Protobuf compiler and verify the `*.proto` files.

## Proposal Requirements

Proposals to add new capabilities to the OpAMP specification must be accompanied by
working prototypes in [opamp-go](https://github.com/open-telemetry/opamp-go),
demonstrating the capability. The prototype can be a PR against opamp-go or can be on
your own fork of opamp-go. The prototype will be used to help aid maintainers in
understanding the implications of the specification changes and how actual usage might
look.

To make a proposal, create a PR in this repo that modifies the specification markdown
and the Protobuf files and include a link to the prototype in the description. We
advise you to attend the OpAMP SIG meeting and discuss your proposal before you spend
effort on it to make sure the proposal is aligned with the SIG's vision.

All new capabilities must be added in
[Development](https://github.com/open-telemetry/opentelemetry-specification/blob/main/oteps/0232-maturity-of-otel.md#development)
maturity level initially. Make sure to add the `[Development]` status label in the
specification markdown and as a prefix of the added proto field or message.

## Contributors

### Maintainers

- [Tigran Najaryan](https://github.com/tigrannajaryan), Splunk

For more information about the maintainer role, see the [community repository](https://github.com/open-telemetry/community/blob/main/guides/contributor/membership.md#maintainer).

### Approvers

- [Andy Keller](https://github.com/andykellr), Bindplane

For more information about the approver role, see the [community repository](https://github.com/open-telemetry/community/blob/main/guides/contributor/membership.md#approver).

### Emeritus Approvers

- [Alex Boten](https://github.com/codeboten), Lightstep
- [Daniel Jaglowski](https://github.com/djaglowski), Bindplane
- [Przemek Maciolek](https://github.com/pmm-sumo), Sumo Logic

For more information about the emeritus role, see the [community repository](https://github.com/open-telemetry/community/blob/main/guides/contributor/membership.md#emeritus-maintainerapprovertriager).

## Implementations

### Libraries

- [OpAMP Go](https://github.com/open-telemetry/opamp-go)

### Agent Management Platforms

- [Bindplane](https://bindplane.com)

### Agents

- [Bindplane Distro for OpenTelemetry Collector](https://github.com/observIQ/bindplane-otel-collector)
- [OpAMP Extension for OpenTelemetry Collector](https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/extension/opampextension)
- [OpAMP Supervisor for OpenTelemetry Collector](https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/cmd/opampsupervisor)
