# OpAMP: Vision and Roadmap

Status: v1

The OpAMP supervisor is a reliable control plane runtime for data collection Agents.  

It enables users to remotely manage large fleets of Agents with operations such as configuration updates, restarts and upgrades. It transforms a set of Agents into a managed, observable fleet while preserving local autonomy and safety. 

## Agent Scope

[OpenTelemetry Collector](https://opentelemetry.io/docs/collector/)

## Desired Outcomes

### The Watchdog 

* When the Collector process crashes due to a memory leak,  
* I want the Supervisor to detect the exit and restart the process immediately,   
* So that I don't get paged at 3 AM for a failure and there is no major telemetry gap 

### Remote Configuration

* When I need to change configuration of the tail sampling processor for 1,000s of OpenTelemetry Collector Agents,   
* I want to push a configuration update from the OpAMP backend that the Supervisor statically validates and reloads the Agents as safely as possible,   
* So that I avoid managing multiple agents via automation tooling such as Ansible, Puppet or manually with incorrect configuration

### Centralized Visibility

* To be able to track the health, version of the fleet of OpenTelemetry Collectors and itself  
* I want the Supervisor to report the agent description including agent version, OS details and the live configuration running at that moment as well as its (Supervisor’s) own telemetry  
* So that I have 100% certainty of the agents running in my infrastructure, understand the status of the supervisor and agents as well as be able to validate agent pipelines, troubleshoot misconfigurations faster

### Agent Lifecycle Management

* When a new version of the OpenTelemetry Collector is released with a critical vulnerability fix,  
* I want the Supervisor to download, verify, and perform the binary update \- but revert immediately if it fails to start,   
* So that I can deploy security patches to production without risking a fleet-wide outage 

## Out of Scope

### User Interface 

The Supervisor is not required to expose any UI or dashboards. Any visual management control plane is expected to be provided by the OpAMP Server implementations. 

### Telemetry Processing

The Supervisor does not touch or alter the telemetry data that the Collector collects and processes. Its job is managing the agent’s configuration and lifecycle \- all tracing / metrics / logging pipelines remain defined in the Collector configuration.

### Orchestration

The Supervisor will not perform a higher level coordination or grouping of agents via policies or templates for operations such as configuration, upgrades. This will be handled by the OpAMP Server or other orchestration tools such as Ansible, Chef. 

### Configuration Merging / Generation

The configuration file merging rules match the rules already in place in the Collector. The Supervisor is not expected to include any logic or implementation to create or merge configuration.

## Guiding Principles

### Reliability and Safety

The Supervisor needs to be highly stable, so we need to keep its complexity and functionality to a minimum. It should never compromise the Collector’s uptime or the telemetry data flow. Changes must be applied safely \- for example, if the new config is invalid or causes the Collector to crash, the Supervisor should detect this and revert to the last good state (gracefully restarting the Collector with the previous config). Similarly, for upgrades, it should verify package integrity (e.g. checksum or signature) and support rollback if a new binary fails. 

### Standardization

All management capabilities (config distribution, status/health reporting, package updates, etc.) will follow the vendor-neutral spec so that any OpAMP-compatible server can work with the Supervisor.

### Self Observability

The Supervisor is a critical component that itself must be observable. It must expose its own health metrics and logs so that users can monitor and troubleshoot its operations (eg. its own resource usage, during remote configuration or validate if an update failed).

### Ease of Use

The Supervisor should be simple to deploy and use \- requiring minimal configuration itself to connect to an OpAMP server and perform supported operations. The documentation to get started and use at scale should be easy to follow.

### Pluggability / Extensibility

Similar to the Collector, the core Supervisor should implement only the minimal, standardized set of OpAMP behaviors. All non-essential or environment-specific functionality must be added through well-defined extension points that are optional, isolated, and independently versioned (eg. contrib).

## Goals

### OpAMP Spec goal

Mark subset of features stable (to be decided), release 1.0

### OpAMP Go

### Implement the stable features of the spec completely and release production-ready 1.0

### Supervisor

Release a product ready MVP Supervisor 1.0

* Implement the MVP features (to be decided)  
* Harden the implementation  
* Make official deb/rpm/etc release, bundled with Collector

## List of Issues 

*Note: This is being split into "will do" and "won't do" lists based on mapping to the goals decided by the maintainers above*

| Issue | OpAMP Spec 1.0 | OpAMP Go 1.0 | Supervisor 1.0 | Notes |
| :---- | :---- | :---- | :---- | :---- |
| [Extend recommendation for agent disconnect to HTTP](https://github.com/open-telemetry/opamp-spec/issues/303) | Y | Y |  |  |
| [Separation of concerns of trusted root authority from distribution server](https://github.com/open-telemetry/opamp-spec/issues/265) | Y | Y |  |  |
| [Sanitization or restriction of Collector configuration](https://github.com/open-telemetry/opentelemetry-collector-contrib/issues/24310) |  |  | Y |  |
| [Updates the Collector binary](https://github.com/open-telemetry/opentelemetry-collector-contrib/pull/35503) |  |  | Y |  |
| [Pre validation](https://github.com/open-telemetry/opentelemetry-collector-contrib/issues/41068) of remote configuration before the process restart   |  |  | Y |  |
| [Expose supervisor metrics (\# restarts, apply errors, messages received, etc.)](https://github.com/open-telemetry/opamp-go/issues/345) |  | Y | Y |  |
| [Support traces (context propagation)](https://github.com/open-telemetry/opamp-go/issues/253) |  | Y | Y |  |
| [Support resource detectors](https://github.com/open-telemetry/opentelemetry-collector-contrib/pull/45118) |  |  | Y |  |
| [Improve OpAMP go documentation](https://github.com/open-telemetry/opamp-go/issues/100) |  | Y |  |  |
| Comprehensive example, possibly [incorporated](https://github.com/open-telemetry/opamp-go/issues/500) in the Otel Demo, including Supervisor and and a Server |  |  | Y |  |
| [Add failure context on remote config updates](https://github.com/open-telemetry/opentelemetry-collector-contrib/issues/44836) |  |  | Y |  |
| Supervise multiple agents per [WebSocket connection](https://github.com/open-telemetry/opamp-go/issues/252) |  | Y |  |  |
| Keep alive [for WebSocket](https://github.com/open-telemetry/opamp-go/issues/397). |  | Y |  |  |
| Scale/performance [testbed](https://github.com/open-telemetry/opamp-go/issues/485) |  | Y | Y |  |

### Out of Scope

Spec

* [Add crash diagnostics field to component health](https://github.com/open-telemetry/opamp-spec/issues/277) \- improved troubleshooting  
* [Add support for HTTP long polling](https://github.com/open-telemetry/opamp-spec/issues/245)

OpAMP supervisor

* More [server commands](https://github.com/open-telemetry/opamp-go/issues/500): start/stop/etc?  
* Support [hot reload](https://github.com/open-telemetry/opentelemetry-collector-contrib/issues/44239) of Supervisor  
* [Additional authentication methods](https://github.com/open-telemetry/opentelemetry-collector-contrib/issues/41756) support between OpAMP server and supervisor

OpAMP extension

* Add support for remote configuration to OpAMP extension

K8S Operator / Supervisor  
Features

* [Report each collector pod instance as agent](https://github.com/open-telemetry/opentelemetry-operator/issues/2489) (instead of entire cluster or overall CRD)

Stability / Safety

* Fallback / [HA mode](https://github.com/open-telemetry/opentelemetry-operator/issues/3822) for OpAMP Bridge

Self Observability

* Report own [internal metrics](https://github.com/open-telemetry/opentelemetry-operator/issues/2773)

Spec Compliance

* [Remote configuration](https://github.com/open-telemetry/opentelemetry-operator/pull/4482) should succeed via OpAMP bridge

## Draft List of Issues 

OpAMP spec   
1.0

* [Extend recommendation for agent disconnect to HTTP](https://github.com/open-telemetry/opamp-spec/issues/303)

Proposals

* [Add crash diagnostics field to component health](https://github.com/open-telemetry/opamp-spec/issues/277) \- improved troubleshooting  
* [Add support for HTTP long polling](https://github.com/open-telemetry/opamp-spec/issues/245)

Complete Pending Issues for Spec Compliance:

* [Sanitization or restriction of Collector configuration](https://github.com/open-telemetry/opentelemetry-collector-contrib/issues/24310)  
* [Updates the Collector binary](https://github.com/open-telemetry/opentelemetry-collector-contrib/pull/40203)

Stability / Safety

* When the OpAMP server is unavailable, [fallback to last known good configuration](https://github.com/open-telemetry/opentelemetry-collector-contrib/pull/45100) from a previous run. If it does not, use an initial configuration specified.  
* When OpAMP server is unavailable, retries with exponential backoff. Expose a configurable option.  
* [Pre validation](https://github.com/open-telemetry/opentelemetry-collector-contrib/issues/41068) of remote configuration before the process restart

Self Observability

* Expose Supervisor specific metrics such as:  
  * \# of start / stop attempts  
  * \# of configuration apply errors  
  * \# messages received (AgentDescription, HealthStatus)  
  * Related opamp-go [issue](https://github.com/open-telemetry/opamp-go/issues/345) and [draft PR](https://github.com/open-telemetry/opamp-go/pull/344)  
* Support traces:  
  * Context [propagation](https://github.com/open-telemetry/opamp-go/issues/253).  
* [Support resource detectors](https://github.com/open-telemetry/opentelemetry-collector-contrib/pull/45118) for telemetry

Documentation and Examples

* A more comprehensive example, possibly [incorporated](https://github.com/open-telemetry/opamp-go/issues/500) in the Otel Demo, including Supervisor and and a Server?  
* [opamp-go documentation](https://github.com/open-telemetry/opamp-go/issues/100) improvements.  
* [opentelemetry docs](https://opentelemetry.io/docs/collector/management/) improvements  
  * Include opamp-bridge

Improved Troubleshooting

* [Add failure context](https://github.com/open-telemetry/opentelemetry-collector-contrib/issues/44836) on remote config updates

Features

* More [server commands](https://github.com/open-telemetry/opamp-go/issues/500): start/stop/etc?  
* Support [hot reload](https://github.com/open-telemetry/opentelemetry-collector-contrib/issues/44239) of Supervisor  
* Supervise multiple agents  
  * Multiple agents per [WebSocket connection](https://github.com/open-telemetry/opamp-go/issues/252)  
* [Additional authentication methods](https://github.com/open-telemetry/opentelemetry-collector-contrib/issues/41756) support between OpAMP server and supervisor  
* Add support for remote configuration to OpAMP extension

opamp-go

* Keep alive [for WebSocket](https://github.com/open-telemetry/opamp-go/issues/397).  
* Scale/performance [testbed](https://github.com/open-telemetry/opamp-go/issues/485)?

K8S Operator / Supervisor

Features

* [Report each collector pod instance as agent](https://github.com/open-telemetry/opentelemetry-operator/issues/2489) (instead of entire cluster or overall CRD)

Stability / Safety

* Fallback / [HA mode](https://github.com/open-telemetry/opentelemetry-operator/issues/3822) for OpAMP Bridge

Self Observability

* Report own [internal metrics](https://github.com/open-telemetry/opentelemetry-operator/issues/2773)

Spec Compliance

* [Remote configuration](https://github.com/open-telemetry/opentelemetry-operator/pull/4482) should succeed via OpAMP bridge

## 

