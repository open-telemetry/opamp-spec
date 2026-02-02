# Changelog

## v0.15.0

* Add OpAMP-Instance-UID request header by @tigrannajaryan in https://github.com/open-telemetry/opamp-spec/pull/284

**Full Changelog**: https://github.com/open-telemetry/opamp-spec/compare/v0.14.0...v0.15.0

## v0.14.0

* Add ProxyConnectionSettings to all connection types by @michel-laterman in https://github.com/open-telemetry/opamp-spec/pull/221

**Full Changelog**: https://github.com/open-telemetry/opamp-spec/compare/v0.13.0...v0.14.0

## v0.13.0

* Add spec change for updating capabilities after initial message by @jaronoff97 in https://github.com/open-telemetry/opamp-spec/pull/217
* Add TLS settings to all connection settings by @michel-laterman in https://github.com/open-telemetry/opamp-spec/pull/205
* Add TLSConnectionSettings message attribute descriptions by @michel-laterman in https://github.com/open-telemetry/opamp-spec/pull/222
* Fix field descriptions in ConnectionSettingsOffers by @johannaojeling in https://github.com/open-telemetry/opamp-spec/pull/237
* Add ConnectionSettingsStatus message and capability by @michel-laterman in https://github.com/open-telemetry/opamp-spec/pull/220

**Full Changelog**: https://github.com/open-telemetry/opamp-spec/compare/v0.12.0...v0.13.0

## v0.12.0

* Change PackageStatus.download_details.download_bytes_per_second to double by @michel-laterman in https://github.com/open-telemetry/opamp-spec/pull/210

**Full Changelog**: https://github.com/open-telemetry/opamp-spec/compare/v0.11.0...v0.12.0

## v0.11.0

* Add downloading state and download_details to PackageStatus by @michel-laterman in https://github.com/open-telemetry/opamp-spec/pull/206
* Add message about available components to AgentDetails by @BinaryFissionGames in https://github.com/open-telemetry/opamp-spec/pull/201

**Full Changelog**: https://github.com/open-telemetry/opamp-spec/compare/v0.10.0...v0.11.0

## v0.10.0

* Replace ULIDs by 16 byte ids and recommend UUID v7 by @tigrannajaryan in https://github.com/open-telemetry/opamp-spec/pull/186
* Amend field names in TLSCertificate message by @tpaschalis in https://github.com/open-telemetry/opamp-spec/pull/195
* Introduce heartbeats by @jaronoff97 in https://github.com/open-telemetry/opamp-spec/pull/190
* Allow setting Headers in DownloadableFile message by @tpaschalis in https://github.com/open-telemetry/opamp-spec/pull/197

**Full Changelog**: https://github.com/open-telemetry/opamp-spec/compare/v0.9.0...v0.10.0

## v0.9.0

* Add CustomMessage capability by @andykellr in https://github.com/open-telemetry/opamp-spec/pull/132

**Full Changelog**: https://github.com/open-telemetry/opamp-spec/compare/v0.8.0...v0.9.0

## v0.8.0

* Define OpAMP Protobuf schema stability guarantees by @tigrannajaryan in https://github.com/open-telemetry/opamp-spec/pull/141
* Mark certain capabilities as Beta by @tigrannajaryan in https://github.com/open-telemetry/opamp-spec/pull/147
* Add missing "config_hash" field to AgentRemoteConfig by @tigrannajaryan in https://github.com/open-telemetry/opamp-spec/pull/151
* Rewrite security recommendation to be non-normative by @tigrannajaryan in https://github.com/open-telemetry/opamp-spec/pull/152
* Remove "Performance and Scale" section by @tigrannajaryan in https://github.com/open-telemetry/opamp-spec/pull/154
* Remove "needs simplification" notice by @tigrannajaryan in https://github.com/open-telemetry/opamp-spec/pull/153
* Add client-initiated certificate request flow (CSR) by @tigrannajaryan in https://github.com/open-telemetry/opamp-spec/pull/162
* Add ComponentHealth message by @mwear in https://github.com/open-telemetry/opamp-spec/pull/168

**Full Changelog**: https://github.com/open-telemetry/opamp-spec/compare/v0.7.0...v0.8.0

## v0.7.0

* Change MAY to SHOULD for Server to Client compression by @tigrannajaryan in https://github.com/open-telemetry/opamp-spec/pull/127
* Remove deleted wording from the spec by @tigrannajaryan in https://github.com/open-telemetry/opamp-spec/pull/128
* Add link to proto directory and update Contributing section by @tigrannajaryan in https://github.com/open-telemetry/opamp-spec/pull/130
* Remove unnecessary recommendation about service.name by @tigrannajaryan in https://github.com/open-telemetry/opamp-spec/pull/135
* Adding a header for WebSocket messages to allow future extensibility by @tigrannajaryan in https://github.com/open-telemetry/opamp-spec/pull/138
* Clarify agent health reporting by @tigrannajaryan in https://github.com/open-telemetry/opamp-spec/pull/137

**Full Changelog**: https://github.com/open-telemetry/opamp-spec/compare/v0.6.0...v0.7.0

## v0.6.0

* Declare OpAMP Beta by @tigrannajaryan in https://github.com/open-telemetry/opamp-spec/pull/104
* Add Libraries, Platforms, and Agents sections to the Implementations by @andykellr in https://github.com/open-telemetry/opamp-spec/pull/108
* Add missing ReportsHealth capability by @tigrannajaryan in https://github.com/open-telemetry/opamp-spec/pull/111
* Add ReportsRemoteConfig capability by @tigrannajaryan in https://github.com/open-telemetry/opamp-spec/pull/115
* Require that instance_uid is ULID instead of only recommending it by @tigrannajaryan in https://github.com/open-telemetry/opamp-spec/pull/116
* Clarify what is Agent, especially when Supervisor is used by @tigrannajaryan in https://github.com/open-telemetry/opamp-spec/pull/117
* Change bitfields from enum to uint64 by @tigrannajaryan in https://github.com/open-telemetry/opamp-spec/pull/125
* Separate the notions of Agent and Client by @PeterF778 in https://github.com/open-telemetry/opamp-spec/pull/122
* Move proto files to opamp-spec repo by @tigrannajaryan in https://github.com/open-telemetry/opamp-spec/pull/126

**Full Changelog**: https://github.com/open-telemetry/opamp-spec/compare/v0.5.0...v0.6.0

## v0.5.0

* Add basic Agent Health reporting by @tigrannajaryan in https://github.com/open-telemetry/opamp-spec/pull/103

**Full Changelog**: https://github.com/open-telemetry/opamp-spec/compare/v0.4.0...v0.5.0

## v0.4.0

* Simplify status compression by @tigrannajaryan in https://github.com/open-telemetry/opamp-spec/pull/102

**Full Changelog**: https://github.com/open-telemetry/opamp-spec/compare/v0.3.0...v0.4.0

## v0.3.0

* Add ability to report general errors in PackageStatuses by @tigrannajaryan in https://github.com/open-telemetry/opamp-spec/pull/83
* Move messages in StatusReport to AgentToServer message by @tigrannajaryan in https://github.com/open-telemetry/opamp-spec/pull/85
* Split connection settings by types by @tigrannajaryan in https://github.com/open-telemetry/opamp-spec/pull/87

**Full Changelog**: https://github.com/open-telemetry/opamp-spec/compare/v0.2.0...v0.3.0

## v0.2.0

* Add support for detached signatures by @tigrannajaryan in https://github.com/open-telemetry/opamp-spec/pull/69
* Set instance_uid by Server on conflict or request for generation by @pmm-sumo in https://github.com/open-telemetry/opamp-spec/pull/63
* Update Spec to include ServerToAgentCommand  by @dsvanlani in https://github.com/open-telemetry/opamp-spec/pull/64
* Define that DownloadFile content hash method is SHA256 by @tigrannajaryan in https://github.com/open-telemetry/opamp-spec/pull/68
* Add plain HTTP transport to OpAMP by @tigrannajaryan in https://github.com/open-telemetry/opamp-spec/pull/70
* Unify addons and agent packages by @tigrannajaryan in https://github.com/open-telemetry/opamp-spec/pull/77
* Clarify how state hashes are used between the Agent and the Server by @tigrannajaryan in https://github.com/open-telemetry/opamp-spec/pull/79

**Full Changelog**: https://github.com/open-telemetry/opamp-spec/compare/v0.1.0...v0.2.0

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
