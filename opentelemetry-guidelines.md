# OpenTelemetry Guidelines

This document provides guidance for language instrumentation agents that use
OpAMP.

## Scope

This guidance is intended for OpenTelemetry language agents that run as part of an instrumented
application process. Examples include auto-instrumentation language agents and similar
instrumentation runtimes built with OpenTelemetry SDKs.

This guidance does not apply to standalone agents such as the OpenTelemetry
Collector.

## Identifying Attributes

Language instrumentation agents MUST copy the following OpenTelemetry SDK
`Resource` attributes into `AgentDescription.identifying_attributes`:

- `service.name`
- `service.instance.id`
- `service.namespace.name`, if present

These identifying attributes MUST match the values that the agent uses in the
Resource of its own telemetry.

## Non-identifying Attributes

Language instrumentation agents SHOULD copy all other OpenTelemetry SDK
`Resource` attributes into `AgentDescription.non_identifying_attributes`,
excluding those added to the identifying attributes (above).

## Rationale

For language instrumentation agents, the `service.*` attributes listed above
define the identity that OpAMP uses to associate an agent with its telemetry.
Copying the remaining Resource attributes into
`AgentDescription.non_identifying_attributes` preserves useful descriptive
context without expanding the agent identity beyond those service attributes.
