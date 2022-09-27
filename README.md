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

Approvers ([@open-telemetry/opamp-spec-approvers](https://github.com/orgs/open-telemetry/teams/opamp-spec-approvers)):

- [Alex Boten](https://github.com/codeboten), Lightstep
- [Andy Keller](https://github.com/andykellr), observIQ
- [Daniel Jaglowski](https://github.com/djaglowski), observIQ

Emeritus Approvers

- [Przemek Maciolek](https://github.com/pmm-sumo), Sumo Logic

Maintainers ([@open-telemetry/opamp-spec-maintainers](https://github.com/orgs/open-telemetry/teams/opamp-spec-maintainers)):

- [Tigran Najaryan](https://github.com/tigrannajaryan), Splunk

## Implementations

### Libraries

- [OpAMP Go](https://github.com/open-telemetry/opamp-go)

### Agent Management Platforms

- [BindPlane OP](https://github.com/observIQ/bindplane-op)

### Agents

- [observIQ Distro for OpenTelemetry Collector](https://github.com/observIQ/observiq-otel-collector)
