# Changelog

## v0.1.0

This is the first draft release of OpAMP spec.

### What's Changed
* Add initial copy of OpAMP spec by @tigrannajaryan in
  https://github.com/open-telemetry/opamp-spec/pull/2
* Rename ErrorResponse to ServerErrorResponse by @tigrannajaryan in
  https://github.com/open-telemetry/opamp-spec/pull/10
* Add server_offered_version to AgentInstallStatus by @tigrannajaryan in
  https://github.com/open-telemetry/opamp-spec/pull/11
* Clarify generation of EffectiveConfig hash by @tigrannajaryan in
  https://github.com/open-telemetry/opamp-spec/pull/30
* Remove Health from Status Report message by @tigrannajaryan in
  https://github.com/open-telemetry/opamp-spec/pull/32
* Change addons and agent packages to only contain one downloadable file by
  @tigrannajaryan in https://github.com/open-telemetry/opamp-spec/pull/29
* Clarify OpAMP communication pattern by @tigrannajaryan in
  https://github.com/open-telemetry/opamp-spec/pull/35
* Add explanation of agent_attributes field by @tigrannajaryan in
  https://github.com/open-telemetry/opamp-spec/pull/34
* Add ability to indicate Capabilities in the protocol by @tigrannajaryan in
  https://github.com/open-telemetry/opamp-spec/pull/33
* Clarify Connection Establishment and Restoring by @tigrannajaryan in
  https://github.com/open-telemetry/opamp-spec/pull/36
* Support both HTTP 503 and 429 for throttling by @pmm-sumo in
  https://github.com/open-telemetry/opamp-spec/pull/37
* Eliminate DataForAgent message by @tigrannajaryan in
  https://github.com/open-telemetry/opamp-spec/pull/42
* Eliminate oneof Body from AgentToServer by @tigrannajaryan in
  https://github.com/open-telemetry/opamp-spec/pull/44
* Delete duplicate server_provided_all_addons_hash field by @tigrannajaryan in
  https://github.com/open-telemetry/opamp-spec/pull/45
* Add version field to Addons by @tigrannajaryan in
  https://github.com/open-telemetry/opamp-spec/pull/41
* Add capabilities field to ServerToAgent by @tigrannajaryan in
  https://github.com/open-telemetry/opamp-spec/pull/46
* Fix capabilities enum name and value by @tigrannajaryan in
  https://github.com/open-telemetry/opamp-spec/pull/47
* Generalize Agent identification by @tigrannajaryan in
  https://github.com/open-telemetry/opamp-spec/pull/48

**Full Changelog**: https://github.com/open-telemetry/opamp-spec/commits/v0.1.0
