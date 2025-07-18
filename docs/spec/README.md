<!--- Hugo front matter used to generate the website version of this page:
title: Open Agent Management Protocol
linkTitle: OpAMP
body_class: otel-docs-spec
github_repo: &repo https://github.com/open-telemetry/opamp-spec
github_project_repo: *repo
path_base_for_github_subdir:
  from: tmp/opamp/index.md
  to: specification.md
cSpell:ignore: bitmask Flipr Fluentd oneof protoc Rpbjpvc varint
--->

## Introduction

Open Agent Management Protocol (OpAMP) is a network protocol for remote
management of large fleets of data collection Agents.

OpAMP allows Agents to report their status to and receive configuration from a
Server and to receive Agent installation package updates from the
Server. The protocol is vendor-agnostic, so the Server can remotely monitor and
manage a fleet of different Agents that implement OpAMP, including a fleet of
mixed Agents from different vendors.

OpAMP supports the following functionality:

* Remote configuration of the Agents.
* Status reporting. The protocol allows the Agent to report the properties of
  the Agent such as its type and version or the operating system type and
  version it runs on. The status reporting also allows the management Server to
  tailor the remote configuration to individual Agents or types of Agents.
* Agent's own telemetry reporting to an
  [OTLP](https://opentelemetry.io/docs/specs/otlp/)-compatible
  backend to monitor Agent's process metrics such as CPU or RAM usage, as well
  as Agent-specific metrics such as rate of data processing.
* Agent heartbeating.
* Management of downloadable Agent-specific packages.
* Secure auto-updating capabilities (both upgrading and downgrading of the
  Agents).
* Connection credentials management, including client-side TLS certificate
  revocation and rotation.

The functionality listed above enables a 'single pane of glass' management view
of a large fleet of mixed Agents (e.g. OpenTelemetry Collector, Fluentd, etc).
