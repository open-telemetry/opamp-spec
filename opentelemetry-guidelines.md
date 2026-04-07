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

Language instrumentation agents SHOULD copy all attributes from the
OpenTelemetry SDK `Resource` into `AgentDescription.identifying_attributes`.

Additional identifying attributes MAY be included if they are needed to
uniquely identify the agent in the deployment environment.

## Non-identifying Attributes

Language instrumentation agents SHOULD leave
`AgentDescription.non_identifying_attributes` empty.

## Rationale

For language instrumentation agents, the OpenTelemetry SDK `Resource` already
defines the identity of the telemetry source. Reusing those attributes in OpAMP
keeps the agent identity aligned with the identity used by the telemetry that
the agent produces.
