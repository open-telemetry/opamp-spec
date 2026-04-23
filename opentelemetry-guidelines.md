# OpenTelemetry Guidelines

This document provides guidance for OpenTelemetry agents that use OpAMP.

## Collector

This guidance is intended for OpenTelemetry Collector.

### Identifying Attributes

The OpenTelemetry Collector SHOULD specify the following attributes in
`AgentDescription.identifying_attributes`:

- `service.name` should be set to the same value that the Agent uses in its own telemetry.
- `service.namespace` if it is used in the environment where the Agent runs.
- `service.version` should be set to version number of the Agent build.
- `service.instance.id` should be set. It may be set equal to the Agent's
  instance uid (equal to ServerToAgent.instance_uid field) or any other value
  that uniquely identifies the Agent in combination with other attributes.
- any other attributes that are necessary for uniquely identifying the Agent's
  own telemetry.

These values SHOULD match the values that the Collector uses in the Resource of its
own telemetry.

### Non-identifying Attributes

The following attributes SHOULD be included in `AgentDescription.non_identifying_attributes`:

- `os.type`, `os.version` - to describe where the Collector runs.
- `host.\*` to describe the host the Collector runs on.
- `cloud.\*` to describe the cloud where the host is located.
- any other relevant Resource attributes that describe this Collector and the
  environment it runs in.
- any user-defined attributes that the end user would like to associate with
  this Collector.

## SDKs

This guidance is intended for OpenTelemetry language agents that run as part of an instrumented
application process. Examples include auto-instrumentation language agents and similar
instrumentation runtimes built with OpenTelemetry SDKs.

### Identifying Attributes

Language instrumentation agents MUST copy the following OpenTelemetry SDK
`Resource` attributes into `AgentDescription.identifying_attributes`:

- `service.name`
- `service.instance.id`
- `service.namespace.name`, if present

These identifying attributes MUST match the values that the agent uses in the
Resource of its own telemetry.

### Non-identifying Attributes

Language instrumentation agents SHOULD copy all other OpenTelemetry SDK
`Resource` attributes into `AgentDescription.non_identifying_attributes`,
excluding those added to the identifying attributes (above).

## Rationale

For language instrumentation agents, the `service.*` attributes listed above
define the identity that OpAMP uses to associate an agent with its telemetry.
Copying the remaining Resource attributes into
`AgentDescription.non_identifying_attributes` preserves useful descriptive
context without expanding the agent identity beyond those service attributes.
