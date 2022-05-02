# OpAMP: Open Agent Management Protocol

Author: Tigran Najaryan, Splunk

Contributors: Chris Green, Splunk

Status: Early Draft (see Open Questions).

Date: September 2021

Note: address all TODO and Open Questions before considering the document ready for final review.

Note 2: this document requires a simplification pass to reduce the scope, size and complexity.

#

<!-- toc -->

- [Introduction](#introduction)
- [Communication Model](#communication-model)
  * [WebSocket Transport](#websocket-transport)
  * [Plain HTTP Transport](#plain-http-transport)
  * [AgentToServer Message](#agenttoserver-message)
      - [instance_uid](#instance_uid)
      - [status_report](#status_report)
      - [package_statuses](#package_statuses)
      - [agent_disconnect](#agent_disconnect)
      - [flags](#flags)
  * [ServerToAgent Message](#servertoagent-message)
  * [Agent to Server State Synchronization](#agent-to-server-state-synchronization)
      - [instance_uid](#instance_uid-1)
      - [error_response](#error_response)
      - [remote_config](#remote_config)
      - [connection_settings](#connection_settings)
      - [packages_available](#packages_available)
      - [flags](#flags-1)
      - [capabilities](#capabilities)
      - [agent_identification](#agent_identification)
      - [command](#command)
  * [ServerErrorResponse Message](#servererrorresponse-message)
      - [type](#type)
      - [error_message](#error_message)
      - [retry_info](#retry_info)
  * [ServerToAgentCommand Message](#servertoagentcommand-message)
- [Operation](#operation)
  * [Status Reporting](#status-reporting)
    + [StatusReport Message](#statusreport-message)
      - [agent_description](#agent_description)
      - [effective_config](#effective_config)
      - [remote_config_status](#remote_config_status)
      - [capabilities](#capabilities-1)
    + [AgentDescription Message](#agentdescription-message)
      - [hash](#hash)
      - [identifying_attributes](#identifying_attributes)
      - [non_identifying_attributes](#non_identifying_attributes)
    + [EffectiveConfig Message](#effectiveconfig-message)
      - [hash](#hash-1)
      - [config_map](#config_map)
    + [RemoteConfigStatus Message](#remoteconfigstatus-message)
      - [hash](#hash-2)
      - [last_remote_config_hash](#last_remote_config_hash)
      - [status](#status)
      - [error_message](#error_message-1)
    + [PackageStatuses Message](#packagestatuses-message)
      - [hash](#hash-3)
      - [packages](#packages)
      - [server_provided_all_packages_hash](#server_provided_all_packages_hash)
    + [PackageStatus Message](#packagestatus-message)
      - [name](#name)
      - [agent_has_version](#agent_has_version)
      - [agent_has_hash](#agent_has_hash)
      - [server_offered_version](#server_offered_version)
      - [server_offered_hash](#server_offered_hash)
      - [status](#status-1)
      - [error_message](#error_message-2)
  * [Connection Settings Management](#connection-settings-management)
    + [OpAMP Connection Setting Offer Flow](#opamp-connection-setting-offer-flow)
    + [Trust On First Use](#trust-on-first-use)
    + [Registration On First Use](#registration-on-first-use)
    + [Revoking Access](#revoking-access)
    + [Certificate Generation](#certificate-generation)
    + [Connection Settings for "Other" Destinations](#connection-settings-for-other-destinations)
    + [ConnectionSettingsOffers Message](#connectionsettingsoffers-message)
      - [hash](#hash-4)
      - [opamp](#opamp)
      - [own_metrics](#own_metrics)
      - [own_traces](#own_traces)
      - [own_logs](#own_logs)
      - [other_connections](#other_connections)
    + [ConnectionSettings Message](#connectionsettings-message)
      - [destination_endpoint](#destination_endpoint)
      - [headers](#headers)
      - [proxy_endpoint](#proxy_endpoint)
      - [proxy_headers](#proxy_headers)
      - [certificate](#certificate)
      - [flags](#flags-2)
    + [Headers Message](#headers-message)
    + [TLSCertificate Message](#tlscertificate-message)
      - [public_key](#public_key)
      - [private_key](#private_key)
      - [ca_public_key](#ca_public_key)
  * [Own Telemetry Reporting](#own-telemetry-reporting)
  * [Configuration](#configuration)
    + [Configuration Files](#configuration-files)
    + [Security Considerations](#security-considerations)
    + [AgentRemoteConfig Message](#agentremoteconfig-message)
  * [Packages](#packages)
    + [Downloading Packages](#downloading-packages)
      - [Step 1](#step-1)
      - [Step 2](#step-2)
      - [Step 3](#step-3)
    + [Package Status Reporting](#package-status-reporting)
    + [Calculating Hashes](#calculating-hashes)
      - [File Hash](#file-hash)
      - [Package Hash](#package-hash)
      - [All Packages Hash](#all-packages-hash)
    + [Security Considerations](#security-considerations-1)
    + [PackagesAvailable Message](#packagesavailable-message)
      - [packages](#packages-1)
      - [all_packages_hash](#all_packages_hash)
    + [PackageAvailable Message](#packageavailable-message)
      - [type](#type-1)
      - [version](#version)
      - [file](#file)
      - [hash](#hash-5)
    + [DownloadableFile Message](#downloadablefile-message)
      - [download_url](#download_url)
      - [content_hash](#content_hash)
      - [signature](#signature)
- [Connection Management](#connection-management)
  * [Establishing Connection](#establishing-connection)
  * [Closing Connection](#closing-connection)
    + [WebSocket Transport, Agent Initiated](#websocket-transport-agent-initiated)
    + [WebSocket Transport, Server Initiated](#websocket-transport-server-initiated)
    + [Plain HTTP Transport](#plain-http-transport-1)
  * [Restoring WebSocket Connection](#restoring-websocket-connection)
  * [Duplicate WebSocket Connections](#duplicate-websocket-connections)
  * [Authentication](#authentication)
  * [Bad Request](#bad-request)
  * [Retrying Messages](#retrying-messages)
  * [Throttling](#throttling)
    + [WebSocket Transport](#websocket-transport-1)
    + [Plain HTTP Transport](#plain-http-transport-2)
- [Security](#security)
  * [General Recommendations](#general-recommendations)
  * [Configuration Restrictions](#configuration-restrictions)
  * [Opt-in Remote Configuration](#opt-in-remote-configuration)
  * [Code Signing](#code-signing)
- [Interoperability](#interoperability)
  * [Interoperability of Partial Implementations](#interoperability-of-partial-implementations)
  * [Interoperability of Future Capabilities](#interoperability-of-future-capabilities)
    + [Ignorable Capability Extensions](#ignorable-capability-extensions)
    + [Non-Ignorable Capability Extensions](#non-ignorable-capability-extensions)
- [Performance and Scale](#performance-and-scale)
- [Open Questions](#open-questions)
- [FAQ for Reviewers](#faq-for-reviewers)
    + [What is WebSocket?](#what-is-websocket)
    + [Why not Use TCP Instead of WebSocket?](#why-not-use-tcp-instead-of-websocket)
    + [Why not alwaysUse HTTP Instead of WebSocket?](#why-not-alwaysuse-http-instead-of-websocket)
    + [Why not Use gRPC Instead of WebSocket?](#why-not-use-grpc-instead-of-websocket)
- [Future Possibilities](#future-possibilities)
- [References](#references)
  * [Agent Management](#agent-management)
  * [Configuration Management](#configuration-management)
  * [Security and Certificate Management](#security-and-certificate-management)
  * [Cloud Provider Support](#cloud-provider-support)
  * [Other](#other)

<!-- tocstop -->

# Introduction

Open Agent Management Protocol (OpAMP) is a network protocol for remote
management of large fleets of data collection Agents.

OpAMP allows Agents to report their status to and receive configuration from a
Server and to receive agent installation package updates from the
server. The protocol is vendor-agnostic, so the Server can remotely monitor and
manage a fleet of different Agents that implement OpAMP, including a fleet of
mixed agents from different vendors.

OpAMP supports the following functionality:

* Remote configuration of the agents.
* Status reporting. The protocol allows the agent to report the properties of
  the agent such as its type and version or the operating system type and
  version it runs on. The status reporting also allows the management server to
  tailor the remote configuration to individual agents or types of agents.
* Agent's own telemetry reporting to an
  [OTLP](https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/protocol/otlp.md)-compatible
  backend to monitor agent's process metrics such as CPU or RAM usage, as well
  as agent-specific metrics such as rate of data processing.
* Management of downloadable agent-specific packages.
* Secure auto-updating capabilities (both upgrading and downgrading of the
  agents).
* Connection credentials management, including client-side TLS certificate
  revocation and rotation.

The functionality listed above enables a 'single pane of glass' management view
of a large fleet of mixed agents (e.g. OpenTelemetry Collector, Fluentd, etc).

# Communication Model


The OpAMP Server manages Agents that implement the client-side of OpAMP
protocol. The Agents can optionally send their own telemetry to an OTLP
destination when directed so by the OpAMP Server. The Agents likely also connect
to other destinations, where they send the data they collect:


```
        ┌────────────┬────────┐           ┌─────────┐
        │            │ OpAMP  │  OpAMP    │ OpAMP   │
        │            │        ├──────────►│         │
        │            │ Client │           │ Server  │
        │            └────────┤           └─────────┘
        │                     │
        │            ┌────────┤           ┌─────────┐
        │            │OTLP    │ OTLP/HTTP │ OTLP    │
        │  Agent     │        ├──────────►│         │
        │            │Exporter│           │ Receiver│
        │            └────────┤           └─────────┘
        │                     │
        │            ┌────────┤
        │            │Other   ├──────────► Other
        │            │Clients ├──────────► Destinations
        └────────────┴────────┘
```


This specification defines the OpAMP network protocol and the expected behavior
for OpAMP Agents and Servers. The OTLP/HTTP protocol is
[specified here](https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/protocol/otlp.md).
The protocols used by the Agent to connect to other destinations are agent
type-specific and are outside the scope of this specification.

OpAMP protocol works over one of the 2 supported transports: plain HTTP
connections and WebSocket connections. Server implementations SHOULD accept both
plain HTTP connections and WebSocket connections. Client implementations may
choose to support either plain HTTP or WebSocket transport, depending on their
needs.

Typically a single Server accepts connections from many agents. Agents
are identified by self-assigned globally unique instance identifiers (or
instance_uid for short). The instance_uid is recorded in each message sent from
the Agent to the Server and from the Server to the Agent.

The default URL path for the connection is /v1/opamp. The URL path MAY be
configurable on the Agent and on the Server.


## WebSocket Transport

One of the supported transports for OpAMP protocol is
[WebSocket](https://datatracker.ietf.org/doc/html/rfc6455). The Agent is a
WebSocket client and the Server is a WebSocket server. The Agent and the Server
communicate using binary data WebSocket messages. The payload of each WebSocket
message is a
[binary serialized Protobuf](https://developers.google.com/protocol-buffers/docs/encoding)
message. The Agent sends AgentToServer Protobuf messages and the Server sends
ServerToAgent Protobuf messages:


```
        ┌───────────────┐                        ┌──────────────┐
        │               │      AgentToServer     │              │
        │               ├───────────────────────►│              │
        │     Agent     │                        │    Server    │
        │               │      ServerToAgent     │              │
        │               │◄───────────────────────┤              │
        └───────────────┘                        └──────────────┘
```


Typically a single Server accepts WebSocket connections from many agents. Agents
are identified by self-assigned or server-assigned globally unique instance
identifiers (or instance_uid for short). The instance_uid is recorded in each
message sent from the Agent to the Server and from the Server to the Agent.

The default URL path for the initial WebSocket's HTTP connection is /v1/opamp.
The URL path MAY be configurable on the Agent and on the Server.

OpAMP is an asynchronous, full-duplex message exchange protocol. The order and
sequence of messages exchanged by the Agent and the Server is defined for each
particular capability in the corresponding section of this specification.

The sequence is normally started by an initiating message triggered by some
external event. For example after the connection is established the Agent sends
a StatusReport message. In this case the "connection established" is the
triggering event and the StatusReport is the initiating message.

Both the Agent and the Server may begin a sequence by sending an initiating
message.

The initiating message may trigger the recipient to send one or more messages
back, which in turn may trigger messages in the opposite direction and so on.
This exchange of messages in both directions continues until the sequence is
over because the goal of the exchange is achieved or the sequence failed with an
error.

Note that the same message may in some cases be the initiating message of the
sequence and in some other cases it may be triggered in response to receiving
some other message. Unlike other protocols in OpAMP there is no strict
separation between "request" and "response" messages types. The role of the
message depends on how the sequence is triggered.

For example the StatusReport message may be the initiating message sent by the
Agent when the Agent connects to the Server for the first time. The StatusReport
message may also be sent by the Agent in response to the Server making a remote
configuration offer to the Agent and Agent reporting that it accepted the
configuration.

See sections under the [Operation](#operation) section for the details of the
message sequences.

The WebSocket transport is typically used when it is necessary to have instant
communication ability from the Server to the Agent without waiting for the Agent
to poll the Server like it is done when using the HTTP transport (see below).

## Plain HTTP Transport

The second supported transport for OpAMP protocol is plain HTTP connection. The
Agent is an HTTP client and the Server is an HTTP client server. The Agent makes
POST requests to the Server. The body of the POST request and response is a
[binary serialized Protobuf](https://developers.google.com/protocol-buffers/docs/encoding)
message. The Agent sends AgentToServer Protobuf messages in the request body and
the Server sends ServerToAgent Protobuf messages in the response body.

OpAMP over HTTP is a synchronous, half-duplex message exchange protocol. The
Agent initiates an HTTP request when it has an AgentToServer message to deliver.
The Server responds to each HTTP request with a ServerToAgent message it wants
to deliver to the Agent. If the Agent has nothing to deliver to the Server the
Agent MUST periodically poll the Server by sending an AgentToServer message
where only [instance_uid](#instance_uid) field is set. This gives the Server an
opportunity to send back in the response any messages that the Server wants to
deliver to the Agent (such as for example a new remote configuration).

The default polling interval when the Agent does have anything to deliver is 30
seconds. This polling interval SHOULD be configurable on the Agent.

When using HTTP transport the sequence of messages is exactly the same as it is
when using the WebSocket transport. The only difference is in the timing:
- When the Server wants to send a message to the Agent, the Server needs to wait
  for the Agent to poll the Server and establish an HTTP request over which the Server's
  message can be sent back as an HTTP response.
- When the Agent wants to send a message to the Server and the Agent has previously sent
  a request to the Server that is not yet responded, the Agent MUST wait until the
  response is received before a new request can be made. Note that the new request in
  this case can be made immediately after the previous response is received, the Agent
  does not need to wait for the polling period between requests.

The Agent MUST set "Content-Type: application/x-protobuf" request header when
using plain HTTP transport. When the Server receives an HTTP request with this
header set it SHOULD assume this is a plain HTTP transport request, otherwise it
SHOULD assume this is a WebSocket transport initiation.

Open Question: do we want to also allow JSON-encoded Protobuf messages? This can
be fairly trivially achieved by requiring "Content-Type: application/json" header.

The Agent MAY compress the request body using gzip method and MUST specify
"Content-Encoding: gzip" in that case. Server implementations MUST honour the 
"Content-Encoding" header and MUST support gzipped or uncompressed request bodies.

The Server MAY compress the response if the Agent indicated it can accept compressed
response via the "Accept-Encoding" header.

## AgentToServer Message

The body of the OpAMP WebSocket message or HTTP body of the request is a binary
serialized Protobuf message AgentToServer as defined below (all messages in this
document are specified in
[Protobuf 3 language](https://developers.google.com/protocol-buffers/docs/proto3)):


```protobuf
message AgentToServer {
    string instance_uid = 1;
    StatusReport status_report = 2;
    PackageStatuses package_statuses = 3;
    AgentDisconnect agent_disconnect = 4;
    AgentToServerFlags flags = 5;
}
```

One or more of the fields (status_report, package_statuses, 
agent_disconnect) MUST be set. The Server should process each field as it is
described in the corresponding [Operation](#operation) section.

#### instance_uid

The instance_uid field is a globally unique identifier of the running instance
of the Agent. The Agent SHOULD self-generate this identifier and make the best
effort to avoid creating an identifier that may conflict with identifiers
created by other Agents. The instance_uid SHOULD remain unchanged for the
lifetime of the agent process. The recommended format for the instance_uid is
[ULID](https://github.com/ulid/spec).

In case the Agent wants to use an identifier generated by the Server, the field
SHOULD be set with a temporary value and RequestInstanceUid flag MUST be set.

#### status_report

The status of the Agent. MUST be set in the first AgentToServer message that the
Agent sends after connecting. This field SHOULD be unset if this information is
unchanged since the last AgentToServer message for this agent was sent in the
stream.

#### package_statuses

The list of the agent packages, including package statuses. This field SHOULD be
unset if this information is unchanged since the last AgentToServer message for
this agent was sent in the stream.

#### agent_disconnect

AgentDisconnect MUST be set in the last AgentToServer message sent from the
agent to the server.

#### flags

Bit flags as defined by AgentToServerFlags bit masks.

```protobuf
enum AgentToServerFlags {
    FlagsUnspecified = 0;

    // Flags is a bit mask. Values below define individual bits.

    // The agent requests server go generate a new instance_uid, which will
    // be sent back in ServerToAgent message
    RequestInstanceUid     = 0x00000001;
}
```


## ServerToAgent Message

The body of the WebSocket message or HTTP response body is a binary serialized
Protobuf message ServerToAgent.

ServerToAgent message is sent from the Server to the Agent either in response to
the AgentToServer message or when the Server has data to deliver to the Agent.

If the Server receives an AgentToServer message and the Server has no data to
send back to the Agent then ServerToAgent message will still be sent, but all
fields except instance_uid will be unset (in that case ServerToAgent serves
simply as an acknowledgement of receipt).

Upon receiving a ServerToAgent message the Agent MUST process it. The processing
that needs to be performed depends on what fields in the message are set. For
details see links to the corresponding sections of this specification from the
field descriptions below.

As a result of this processing the Agent may need to send status reports to the
Server. The Agent is free to perform all the processing of the ServerToAgent
message completely and then send one status report or it may send multiple
status reports as it processes the portions of ServerToAgent message to indicate
the progress (see e.g. [Downloading Packages](#downloading-packages)). Multiple status
reports may be desirable when processing takes a long time, in which case the
status reports allow the Server to stay informed.

Note that the Server will reply to each status report with a ServerToAgent
message (or with an ServerErrorResponse if something goes wrong). These
ServerToAgent messages may have the same content as the one received earlier or
the content may be different if the situation on the Server has changed. The
Agent SHOULD be ready to process these additional ServerToAgent messages as they
arrive.

The Agent SHOULD NOT send any status reports at all if the status of the Agent
did not change as a result of processing.

The ServerToAgent message has the following structure:

```protobuf
message ServerToAgent {
    string instance_uid = 1;
    ServerErrorResponse error_response = 2;
    AgentRemoteConfig remote_config = 3;
    ConnectionSettingsOffers connection_settings = 4;
    PackagesAvailable packages_available = 5;
    Flags flags = 6;
    ServerCapabilities capabilities = 7;
    AgentIdentification agent_identification = 8;
    ServerToAgentCommand command = 9;
}
```

## Agent to Server State Synchronization

The Agent notifies the Server about Agent's state by sending AgentToServer messages.
The state for example includes the agent description, its effective configuration,
the status of the remote configuration it received from the server and the status
of the packages. The Server tracks the state of the Agent using the data
specified in the messages referenced from AgentToServer message.

The Agent MAY compress some of these messages by omitting the data that has not changed
since that particular data was reported last time. The following messages can be subject
to such compression:
[AgentDescription](#agentdescription-message),
[EffectiveConfig](#effectiveconfig-message),
[RemoteConfigStatus](#remoteconfigstatus-message) and 
[PackageStatuses](#packagestatuses-message).

The compression is done by omitting all fields in the message, except
the hash field which MUST always be present (see below for how the hash field is used).
If any of the fields in the message has changed then the compression cannot be used
and all fields MUST be present.

If all AgentToServer messages are reliably delivered to the Server and the Server
correctly processes them then such compression is safe and the Server should always
have the correct latest state of the Agent. 

However, it is possible that the Agent and Server lose the synchronization and the Agent
believes the Server has the latest data while in reality the Server doesn't. This is
possible for example if the Server is restarted while the Agent keeps running and sends
AgentToServer messages, which the Server does not receive because it is temporarily down.

In order to detect this situation and recover from it, every compressible message
contains a hash field. The field is the hash of the content of every other field.
The hash is computed on full, uncompressed message (as if no compression is used) and
then unchanged fields may be omitted from the message. Note that either all fields in the
message must be present or all fields (except hash) must be omitted.

The Server SHOULD store the received hash value for each message type. When the Server
receives a message of the same type with a hash value that is different from the last
stored hash and with omitted data then the Server knows it has lost the state of this
particular message.

When this situation is encountered, to recover the lost state the Server MUST request
the Agent to report the omitted data. To make this request the Server MUST send
a ServerToAgent message to the Agent and set the corresponding `Report*` bit in
the [flags](#flags-1) field of [ServerToAgent message](#servertoagent-message).
The flags field contains one `Report*` bit per type of compressible message.

For the details of the flags field see the [descriptions here](#flags-1).

#### instance_uid

The Agent instance identifier. MUST match the instance_uid field previously
received in the AgentToServer message. When communication with multiple Agents
is multiplexed into one WebSocket connection (for example when a terminating
proxy is used) the instance_uid field allows to distinguish which Agent the
ServerToAgent message is addressed to.

Note: the value can be overriden by server by sending a new one in the
AgentIdentification field. When this happens then Agent MUST update its
instance_uid to the value provided and use it for all further communication.

#### error_response

error_response is set if the Server wants to indicate that something went wrong
during processing of an AgentToServer message. If error_response is set then all
other fields below must be unset and vice versa, if any of the fields below is
set then error_response must be unset.

#### remote_config


This field is set when the Server has a remote config offer for the Agent. See
[Configuration](#configuration) for details.

#### connection_settings


This field is set when the Server wants the Agent to change one or more of its
client connection settings (destination, headers, certificate, etc). See
[Connection Settings Management](#connection-settings-management) for details.

#### packages_available

This field is set when the Server has packages to offer to the Agent. See
[Packages](#packages) for details.

#### flags

Bit flags as defined by Flags bit masks.

`Report*` flags can be used by the Server if the Agent did not include the
particular portion of the data in the last AgentToServer message (which is an allowed
compression approach) but the Server does not have that data, e.g. the Server was
restarted and lost the state (see the details in
[this section](#agent-to-server-state-synchronization)).


```protobuf
enum Flags {
    FlagsUnspecified = 0;

    // Flags is a bit mask. Values below define individual bits.

    // The server asks the agent to report full AgentDescription.
    ReportAgentDescription   = 0x00000001;

    // The server asks the agent to report full EffectiveConfig. This bit MUST NOT be
    // set if the Agent indicated it cannot report effective config by setting
    // the ReportsEffectiveConfig bit to 0 in StatusReport.capabilities field.
    ReportEffectiveConfig    = 0x00000002;
  
    // The server asks the agent to report full RemoteConfigStatus. This bit MUST NOT be
    // set if the Agent indicated it cannot accept remote config by setting
    // the AcceptsRemoteConfig bit to 0 in StatusReport.capabilities field.
    ReportRemoteConfigStatus = 0x00000004;

    // The server asks the agent to report full PackageStatuses. This bit MUST NOT be
    // set if the Agent indicated it cannot report package status by setting
    // the ReportsPackageStatuses bit to 0 in StatusReport.capabilities field.
    ReportPackageStatuses     = 0x00000008;
}
```

#### capabilities

Bitmask of flags defined by ServerCapabilities enum. All bits that are not
defined in ServerCapabilities enum MUST be set to 0 by the Server. This allows
extending the protocol and the ServerCapabilities enum in the future such that
old Servers automatically report that they don't support the new capability.
This field MUST be set in the first ServerToAgent sent by the Server and MAY be
omitted in subsequent ServerToAgent messages by setting it to
UnspecifiedServerCapability value.

```protobuf
enum ServerCapabilities {
    // The capabilities field is unspecified.
    UnspecifiedServerCapability = 0;
    // The Server can accept status reports. This bit MUST be set, since all Server
    // MUST be able to accept status reports.
    AcceptsStatus                  = 0x00000001;
    // The Server can offer remote configuration to the Agent.
    OffersRemoteConfig             = 0x00000002;
    // The Server can accept EffectiveConfig in StatusReport.
    AcceptsEffectiveConfig         = 0x00000004;
    // The Server can offer Packages.
    OffersPackages                 = 0x00000008;
    // The Server can accept Packages status.
    AcceptsPackagesStatus          = 0x00000010;
    // The Server can offer connection settings.
    OffersConnectionSettings       = 0x00000020;

    // Add new capabilities here, continuing with the least significant unused bit.
}
```


#### agent_identification

Properties related to identification of the agent, which can be overriden by the
server if needed. When new_instance_uid is set, Agent MUST update instance_uid
to the value provided and use it for all further communication.

```protobuf
message AgentIdentification {
  string new_instance_uid = 1;
}
```

#### command

This field is set when the server wants the agent to
perform a restart. This field must not be set with other fields
besides instance_uid or capabilities. All other fields will be ignored and the
agent will execute the command. See [ServerToAgentCommand Message](#servertoagentcommand-message)
for details.

## ServerErrorResponse Message


The message has the following structure:


```protobuf
message ServerErrorResponse {
    enum Type {
        UNKNOWN = 0;
        BAD_REQUEST = 1;
        UNAVAILABLE = 2
    }
    Type type = 1;
    string error_message = 2;
    oneof Details {
        RetryInfo retry_info = 3;
    }
}
```



#### type


This field defines the type of the error that the Server encountered when trying
to process the Agent's request. Possible values are:

UNKNOWN: Unknown error. Something went wrong, but it is not known what exactly.
The error_message field may contain a description of the problem.

BAD_REQUEST: Only sent as a response to a previously received AgentToServer
message and indicates that the AgentToServer message was malformed. See
[Bad Request](#bad-request) processing.

UNAVAILABLE: The server is overloaded and unable to process the request. See
[Throttling](#throttling).

#### error_message


Error message, typically human readable.

#### retry_info


Additional [RetryInfo](#throttling) message about retrying if type==UNAVAILABLE.

## ServerToAgentCommand Message
 

The message has the following structure:

```protobuf
// ServerToAgentCommand is sent from the server to the agent to request that the agent
// perform a command.
message ServerToAgentCommand {
    enum CommandType {
        // The agent should restart. This request will be ignored if the agent does not
        // support restart.
        Restart = 0;
    }
    CommandType type = 1;
}
```

The ServerToAgentCommand message is sent when the Server wants the Agent to restart.
This message must only contain the command, instance_uid, and capabilities fields.  All other fields
will be ignored.

# Operation


## Status Reporting


The Agent MUST send a status report:



* First time immediately after connecting to the Server. The status report MUST
  be the first message sent by the Agent.
* Subsequently every time the status of the Agent changes.

The status report is set as a [status_report](#statusreport-message) field in the
AgentToServer message.

The Server MUST respond to the status report by sending a
[ServerToAgent](#servertoagent-message) message.

If the status report processing failed then the
[error_response](#error_response) field MUST be set to ServerErrorResponse
message.

If the status report is processed successfully by the Server then the
[error_response](#error_response) field MUST be unset and the other fields can
be populated as necessary.

Here is the sequence diagram that shows how status reporting works (assuming
server-side processing is successful):


```
        Agent                                  Server

          │                                       │
          │                                       │
          │          WebSocket Connect            │
          ├──────────────────────────────────────►│
          │                                       │
          │     AgentToServer{StatusReport}       │   ┌─────────┐
          ├──────────────────────────────────────►├──►│         │
          │                                       │   │ Process │
          │           ServerToAgent{}             │   │ Status  │
          │◄──────────────────────────────────────┤◄──┤         │
          │                                       │   └─────────┘
          .                 ...                   .

          │     AgentToServer{StatusReport}       │   ┌─────────┐
          ├──────────────────────────────────────►├──►│         │
          │                                       │   │ Process │
          │           ServerToAgent{}             │   │ Status  │
          │◄──────────────────────────────────────┤◄──┤         │
          │                                       │   └─────────┘
          │                                       │
```


Note that the status of the Agent may change as a result of receiving a message
from the Server. For example the Server may send a remote configuration to the
Agent. Once the Agent processes such a request the Agent's status changes (e.g.
the effective configuration of the Agent changes). Such status change should
result in the Agent sending a status report to the Server.

So, essentially in such cases the sequence of messages may look like this:


```
                   Agent                                  Server

                    │         ServerToAgent{}               │
            ┌───────┤◄──────────────────────────────────────┤
            │       │                                       │
            ▼       │                                       │
        ┌────────┐  │                                       │
        │Process │  │                                       │
        │Received│  │                                       │
        │Data    │  │                                       │
        └───┬────┘  │                                       │
            │       │                                       │
            │Status │                                       │
            │Changed│   AgentToServer{StatusReport}         │   ┌─────────┐
            └──────►├──────────────────────────────────────►├──►│         │
                    │                                       │   │ Process │
                    │         ServerToAgent{}               │   │ Status  │
                    │◄──────────────────────────────────────┤◄──┤         │
                    │                                       │   └─────────┘
```


When the Agent receives a ServerToAgent message the Agent MUST NOT send a status
report unless processing of the message received from the Server resulted in
actual change of the Agent status (e.g. the configuration of the Agent has
changed). The sequence diagram in this case look like this:


```
                     Agent                                  Server

                       │         ServerToAgent{}               │
                ┌──────┤◄──────────────────────────────────────┤
                │      │                                       │
                ▼      │                                       │
            ┌────────┐ │                                       │
            │Process │ │                                       │
            │Received│ │                                       │
            │Data    │ │                                       │
            └───┬────┘ │                                       │
                │      │                                       │
                ▼      │                                       │
             No Status │                                       │
              Changes  │                                       │
                       │                                       │
                       │                                       │
```


Important: if the Agent does not follow these rules the operation may result in
an infinite loop of messages sent back and forth between the Agent and the
Server. TODO: add a section explaining how infinite oscillations between remote
config and status reporting are possible if an attribute is reported in the
status that can be changed via remote config and how to prevent it.

### StatusReport Message

StatusReport message has the following structure:

```protobuf
message StatusReport {
    AgentDescription agent_description = 1;
    EffectiveConfig effective_config = 2;
    RemoteConfigStatus remote_config_status = 3;
    AgentCapabilities capabilities = 4;
}
```

#### agent_description

The description of the agent, its type, where it runs, etc. See
[AgentDescription](#agentdescription-message) message for details.

#### effective_config

The current effective configuration of the Agent. The effective configuration is
the one that is currently used by the Agent. The effective configuration may be
different from the remote configuration received from the Server earlier, e.g.
because the agent uses a local configuration instead (or in addition). See
[EffectiveConfig](#effectiveconfig-message) message for details.

#### remote_config_status

The status of the remote config that was previously received from the server.
See [RemoteConfigStatus](#remoteconfigstatus-message) message for details.

#### capabilities

Bitmask of flags defined by AgentCapabilities enum. All bits that are not
defined in AgentCapabilities enum MUST be set to 0 by the Agent. This allows
extending the protocol and the AgentCapabilities enum in the future such that
old Agents automatically report that they don't support the new capability. This
field MUST be set in the first StatusReport sent by the Agent and MAY be omitted
in subsequent StatusReport messages by setting it to UnspecifiedAgentCapability
value.

```protobuf
enum AgentCapabilities {
    // The capabilities field is unspecified.
    UnspecifiedAgentCapability = 0;
    // The Agent can report status. This bit MUST be set, since all Agents MUST
    // report status.
    ReportsStatus                  = 0x00000001;
    // The Agent can accept remote configuration from the Server.
    AcceptsRemoteConfig            = 0x00000002;
    // The Agent will report EffectiveConfig in StatusReport.
    ReportsEffectiveConfig         = 0x00000004;
    // The Agent can accept package offers.
    AcceptsPackages                = 0x00000008;
    // The Agent can report package status.
    ReportsPackageStatuses         = 0x00000010;
    // The Agent can report own trace to the destination specified by
    // the Server via ConnectionSettingsOffers.own_traces field.
    ReportsOwnTraces               = 0x00000020;
    // The Agent can report own metrics to the destination specified by
    // the Server via ConnectionSettingsOffers.own_metrics field.
    ReportsOwnMetrics              = 0x00000040;
    // The Agent can report own logs to the destination specified by
    // the Server via ConnectionSettingsOffers.own_logs field.
    ReportsOwnLogs                 = 0x00000080;
    // The can accept connections settings for OpAMP via
    // ConnectionSettingsOffers.opamp field.
    AcceptsOpAMPConnectionSettings = 0x00000100;
    // The can accept connections settings for other destinations via
    // ConnectionSettingsOffers.other_connections field.
    AcceptsOtherConnectionSettings = 0x00000200;
    // The Agent can accept restart requests.
    AcceptsRestartCommand          = 0x00000400;

    // Add new capabilities here, continuing with the least significant unused bit.
}
```

### AgentDescription Message

The AgentDescription message has the following structure:

```protobuf
message AgentDescription {
    bytes hash = 1;
    repeated KeyValue identifying_attributes = 2;
    repeated KeyValue non_identifying_attributes = 3;
}
```

#### hash

The hash of the content of all other fields (even if the other fields are omitted
for compression). See [Agent To Server State Synchronization](#agent-to-server-state-synchronization)
for details about hash field usage.

#### identifying_attributes

Attributes that identify the agent.

Keys/values are according to OpenTelemetry semantic conventions, see:
https://github.com/open-telemetry/opentelemetry-specification/tree/main/specification/resource/semantic_conventions

For standalone running Agents (such as OpenTelemetry Collector) the following
attributes SHOULD be specified:

- service.name should be set to a reverse FQDN that uniquely identifies the
  agent type, e.g. "io.opentelemetry.collector"
- service.namespace if it is used in the environment where the Agent runs.
- service.version should be set to version number of the Agent build.
- service.instance.id should be set. It may be be set equal to the Agent's
  instance uid (equal to ServerToAgent.instance_uid field) or any other value
  that uniquely identifies the Agent in combination with other attributes.
- any other attributes that are necessary for uniquely identifying the Agent's
  own telemetry.

The Agent SHOULD also include these attributes in the Resource of its own
telemetry. The combination of identifying attributes SHOULD be sufficient to
uniquely identify the Agent's own telemetry in the destination system to which
the Agent sends its own telemetry.

This field MUST be set if the Agent has received the ReportAgentDescription flag in the
ServerToAgent message.

#### non_identifying_attributes

Attributes that do not necessarily identify the Agent but help describe where it
runs.

The following attributes SHOULD be included:

- os.type, os.version - to describe where the agent runs.
- host.* to describe the host the agent runs on.
- cloud.* to describe the cloud where the host is located.
- any other relevant Resource attributes that describe this agent and the
  environment it runs in.
- any user-defined attributes that the end user would like to associate with
  this agent.

This field MUST be set if the Agent has received the ReportAgentDescription flag in the
ServerToAgent message.

### EffectiveConfig Message

The EffectiveConfig message has the following structure:

```protobuf
message EffectiveConfig {
    bytes hash = 1;
    AgentConfigMap config_map = 2;
}
```

#### hash

The hash of the content of all other fields (even if the other fields are omitted
for compression). See [Agent To Server State Synchronization](#agent-to-server-state-synchronization)
for details about hash field usage.

#### config_map

The effective config of the Agent. SHOULD be omitted if unchanged since last
reported.

MUST be set if the Agent has received the ReportEffectiveConfig flag in the
ServerToAgent message.

See AgentConfigMap message definition in the [Configuration](#configuration)
section.

### RemoteConfigStatus Message

The RemoteConfigStatus message has the following structure:

```protobuf
message RemoteConfigStatus {
    bytes hash = 1;
    bytes last_remote_config_hash = 2;
    enum Status {
        // The value of status field is not set.
        UNSET = 0;
      
        // Remote config was successfully applied by the Agent.
        APPLIED = 1;

        // Agent is currently applying the remote config that it received earlier.
        APPLYING = 2;

        // Agent tried to apply the config received earlier, but it failed.
        // See error_message for more details.
        FAILED = 3;
    }
    Status status = 3;
    string error_message = 4;
}
```

#### hash

The hash of the content of all other fields (even if the other fields are omitted
for compression). See [Agent To Server State Synchronization](#agent-to-server-state-synchronization)
for details about hash field usage.

#### last_remote_config_hash

The hash of the remote config that was last received by this agent from the
management server. The server SHOULD compare this hash with the config hash it
has for the agent and if the hashes are different the server MUST include the
remote_config field in the response in the ServerToAgent message.

#### status

The status of the Agent's attempt to apply a previously received remote
configuration.

#### error_message

Optional error message if status==FAILED.

### PackageStatuses Message

The PackageStatuses message describes the status of all packages that the agent
has or was offered. The message has the following structure:

```protobuf
message PackageStatuses {
    bytes hash = 1;
    map<string, PackageStatus> packages = 2;
    bytes server_provided_all_packages_hash = 3;
}
```

#### hash

The hash of the content of all other fields (even if the other fields are omitted
for compression). See [Agent To Server State Synchronization](#agent-to-server-state-synchronization)
for details about hash field usage.

#### packages

A map of PackageStatus messages, where the keys are package names. The key MUST
match the name field of [PackageStatus](#packagestatus-message) message.

#### server_provided_all_packages_hash

The aggregate hash of all packages that this Agent previously received from the
server via PackagesAvailable message.

The server SHOULD compare this hash to the aggregate hash of all packages that it
has for this Agent and if the hashes are different the server SHOULD send an
PackagesAvailable message to the agent.

### PackageStatus Message

The PackageStatus has the following structure:

```protobuf
message PackageStatus {
    string name = 1;
    string agent_has_version = 2;
    bytes agent_has_hash = 3;
    string server_offered_version = 4;
    bytes server_offered_hash = 5;
    enum Status {
        INSTALLED = 0;
        INSTALLING = 1;
        INSTALL_FAILED = 2;
    }
    Status status = 6;
    string error_message = 7;
}
```

#### name

Package name. MUST be always set and MUST match the key in the packages field of
PackageStatuses message.

#### agent_has_version

The version of the package that the Agent has.

MUST be set if the Agent has this package.

MUST be empty if the Agent does not have this package. This may be the case for
example if the package was offered by the Server but failed to install and the
agent did not have this package previously.

#### agent_has_hash

The hash of the package that the Agent has.

MUST be set if the Agent has this package.

MUST be empty if the Agent does not have this package. This may be the case for
example if the package was offered by the Server but failed to install and the
agent did not have this package previously.

#### server_offered_version

The version of the package that the server offered to the agent.

MUST be set if the installation of the package is initiated by an earlier offer
from the server to install this package.

MUST be empty if the Agent has this package but it was installed locally and was
not offered by the server.

Note that it is possible for both agent_has_version and server_offered_version
fields to be set and to have different values. This is for example possible if
the agent already has a version of the package successfully installed, the server
offers a different version, but the agent fails to install that version.

#### server_offered_hash

The hash of the package that the server offered to the agent.

MUST be set if the installation of the package is initiated by an earlier offer
from the server to install this package.

MUST be empty if the Agent has this package but it was installed locally and was
not offered by the server.

Note that it is possible for both agent_has_hash and server_offered_hash fields
to be set and to have different values. This is for example possible if the
agent already has a version of the package successfully installed, the server
offers a different version, but the agent fails to install that version.

#### status


The status of this package. The possible values are:

INSTALLED: Package is successfully installed by the Agent. The error_message field
MUST NOT be set.

INSTALLING: Agent is currently downloading and installing the package.
server_offered_hash field MUST be set to indicate the version that the agent is
installing. The error_message field MUST NOT be set.

INSTALL_FAILED: Agent tried to install the package but installation failed.
server_offered_hash field MUST be set to indicate the version that the agent
tried to install. The error_message may also contain more details about the
failure.

#### error_message


An error message if the status is erroneous.


## Connection Settings Management


OpAMP includes features that allow the Server to manage Agent's connection
settings for all of the destinations that the agent connects to.

The following diagram shows a typical Agent that is managed by OpAMP Servers,
sends its own telemetry to an OTLP backend and also connects to other
destinations to perform its work:


```
            ┌────────────┬────────┐           ┌─────────┐
            │            │ OpAMP  │  OpAMP    │ OpAMP   │
            │            │        ├──────────►│         │
            │            │ Client │           │ Server  │
            │            └────────┤           └─────────┘
            │                     │
            │            ┌────────┤           ┌─────────┐
            │            │OTLP    │ OTLP/HTTP │OTLP     │
            │  Agent     │        ├──────────►│Telemetry│
            │            │Client  │           │Backend  │
            │            └────────┤           └─────────┘
            │                     │
            │            ┌────────┤
            │            │Other   ├──────────► Other
            │            │        ├──────────► 
            │            │Clients ├──────────► Destinations
            └────────────┴────────┘
```


When connecting to the OpAMP Server and to other destinations it is typically
expected that Agents will use some sort of header-based authorization mechanism
(e.g. an "Authorization" HTTP header or an access token in a custom header) and
optionally also client-side certificates for TLS connections (also known as
mutual TLS).

OpAMP protocol allows the Server to offer settings for each of these connections
and for the Agent to accept or reject such offers. This mechanism can be used to
direct the Agent to a specific destination, as well as for access token and TLS
certificate registration, revocation and rotation as needed.

The Server can offer connection settings for the following 3 classes of
destinations:



1. The **OpAMP Server** itself. This is typically used to manage credentials
   such as the TLS certificate or the request headers that are used for
   authorization. The Server MAY also offer a different destination endpoint to
   direct the Agent to connect to a different OpAMP Server.
2. The destinations for the Agent to send its **own telemetry**: metrics, traces
   and logs using OTLP/HTTP protocol.
3. A set of **additional "other" connection** settings, with a string name
   associated with each. How the agent type uses these is agent-specific.
   Typically the name represents the name of the destination to connect to (as
   it is known to the agent). For example OpenTelemetry Collector can use the
   named connection settings for its exporters, one named connection setting per
   correspondingly named exporter.

The Server may make an offer for the particular connection class only if the
corresponding capability to use the connection is reported by the Agent via
StatusReport.capabilities field:

- If ReportsOwnTraces capability bit is set the Server may offer connection
  settings for traces using own_traces field.
- If ReportsOwnMetrics capability bit is set the Server may offer connection
  settings for metrics using own_metrics field.
- If ReportsOwnLogs capability bit is set the Server may offer connection
  settings for logs using own_logs field.
- If AcceptsOpAMPConnectionSettings capability bit is set the Server may offer
  connection settings for OpAMP connection using opamp field.
- If AcceptsOtherConnectionSettings capability bit is set the Server may offer
  connection settings for other destinations using other_connections field.

Depending on which connection settings are offered the sequence of operations is
slightly different. The handling of connection settings for own telemetry is
described in [Own Telemetry Reporting](#own-telemetry-reporting). The handling
of connection settings for "other" destinations is described in
[Connection Settings for "Other" Destinations](#connection-settings-for-"other"-destinations).
The handling of OpAMP connection settings is described below.

### OpAMP Connection Setting Offer Flow


Here is how the OpAMP connection settings change happens:


```
                   Agent                                 Server

                     │                                       │    Initiate
                     │    Connect                            │    Settings
                     ├──────────────────────────────────────►│     Change
                     │                 ...                   │        │
                     │                                       │◄───────┘
                     │                                       │          ┌───────────┐
                     │                                       ├─────────►│           │
                     │                                       │ Generate │Credentials│
┌───────────┐        │ServerToAgent{ConnectionSettingsOffers}│ and Save │   Store   │
│           │◄───────┤◄──────────────────────────────────────┤◄─────────┤           │
│Credentials│ Save   │                                       │          └───────────┘
│   Store   │        │             Disconnect                │
│           ├───────►├──────────────────────────────────────►│
└───────────┘        │                                       │
                     │    Connect, New settings              │          ┌───────────┐
                     ├──────────────────────────────────────►├─────────►│           │
                     │                                       │ Delete   │Credentials│
┌───────────┐        │    Connection established             │ old      │   Store   │
│           │◄───────┤◄─────────────────────────────────────►│◄─────────┤           │
│Credentials│Delete  │                                       │          └───────────┘
│   Store   │old     │                                       │
│           ├───────►│                                       │
└───────────┘        │                                       │

```



1. Server generates new connection settings and saves it in Server's credentials
   store, associating the new settings with the Agent instance UID.
2. Server sends the ServerToAgent message that includes
   [ConnectionSettingsOffers](#connectionsettingsoffers-message) message. The
   [opamp](#opamp) field contains the new
   [ConnectionSettings](#connectionsettings-message) offered. The server sets
   only the fields that it wants to change in the
   [ConnectionSettings](#connectionsettings-message) message. The server can
   offer to replace a single field (e.g. only the [headers](#headers)) or
   several of the fields at once.
3. Agent receives the settings offer and updates the fields that the offer
   includes on top of its current connection settings, then saves the updated
   connection settings in the local store, marking it as "candidate" (if Agent
   crashes it will retry "candidate" validation steps 5-9).
4. Agent disconnects from the Server.
5. Agent connects to the Server, using the new settings.
6. Connection is successfully established, any TLS verifications required are
   passed and the server indicates a successful authorization.
7. Server deletes the old connection settings for this agent (using Agent
   instance UID) from its credentials store.
8. Agent deletes the old settings from its credentials store and marks the new
   connection settings as "valid".
9. If step 6 fails the Agent deletes the new settings and reverts to the old
   settings and reconnects.

Note: Agents which are unable to persist new connection settings and have access
only to ephemeral storage SHOULD reject certificate offers otherwise they risk
losing access after restarting and losing the offered certificate.

### Trust On First Use


Agents that want to use TLS with a client certificate but do not initially have
a certificate can use the Trust On First Use (TOFU) flow. The sequence is the
following:



* Agent connects to the Server using regular TLS (validating Server's identity)
  but without a client certificate. Agent sends its Status Report so that it can
  be identified.
* The Server accepts the connection and status and awaits for an approval to
  generate a client certificate for the Agent.
* Server either waits for a manual approval by a human or automatically approves
  all TOFU requests if the Server is configured to do so (can be a server-side
  option).
* Once approved the flow is essentially identical to
  [OpAMP Connection Setting Offer Flow](#opamp-connection-setting-offer-flow)
  steps, except that there is no old client certificate to delete.

TOFU flow allows to bootstrap a secure environment without the need to perform
Agent-side installation of certificates.

Exact same TOFU approach can be also used for Agents that don't have the
necessary authorization headers to access the Server. The Server can detect such
access and upon approval send the authorization headers to the Agent.

### Registration On First Use


In some use cases it may be desirable to equip newly installed Agents with an
initial connection settings that are good for the first use, but generate a new
set of connection credentials after the first connection is established.

This can be achieved very similarly to how the TOFU flow works. The only
difference is that the first connection will be properly authenticated, but the
Server will immediately generate and offer new connection settings to the Agent.
The Agent will then persist the setting and will use them for all subsequent
operations.

This allows deploying a large number of Agents using one pre-defined set of
connection credentials (authorization headers, certificates, etc), but
immediately after successful connection each Agent will acquire their own unique
connection credentials. This way individual Agent's credentials may be revoked
without disrupting the access to all other Agents.

### Revoking Access


Since the Server knows what access headers and a client certificate the Agent
uses, the Server can revoke access to individual Agents by marking the
corresponding connection settings as "revoked" and disconnecting the Agent.
Subsequent connections using the revoked credentials can be rejected by the
Server essentially prohibiting the Agent to access the Server.

Since the Server has control over the connection settings of all 3 destination
types of the Agent (because it can offer the connection settings) this
revocation may be performed for either of the 3 types of the destinations,
provided that the Server previously offered and the Agent accepted the
particular type of destination.

For own telemetry and "other" destinations the Server MUST also communicate the
revocation fact to the corresponding destinations so that they can begin
rejecting access to connections that use the revoked credentials.

### Certificate Generation


Client certificates that the Server generates may be self-signed, signed by a
private Certificate Authority or signed by a public Certificate Authority. The
Server is responsible for generating client certificates such that they are
trusted by the destination the certificate is intended for. This requires that
either the destinations remember and trust the individual self-signed client
certificate's public key directly or they trust the Certificate Authority that
is used for signing the client certificate so that the trust chain can be
verified.

How exactly the client certificates are generated is outside the scope of the
OpAMP specification.

### Connection Settings for "Other" Destinations


TBD

### ConnectionSettingsOffers Message


ConnectionSettingsOffers message describes connection settings for the agent to
use:


```protobuf
message ConnectionSettingsOffers {
    bytes hash = 1;
    ConnectionSettings opamp = 2;
    ConnectionSettings own_metrics = 3;
    ConnectionSettings own_traces = 4;
    ConnectionSettings own_logs = 5;
    map<string,ConnectionSettings> other_connections = 6;
}
```


#### hash

Hash of all settings, including settings that may be omitted from this message
because they are unchanged.

#### opamp

Settings to connect to the OpAMP server. If this field is not set then the agent
should assume that the settings are unchanged and should continue using existing
settings. The agent MUST verify the offered connection settings by actually
connecting before accepting the setting to ensure it does not lose access to
the OpAMP server due to invalid settings.

#### own_metrics

Settings to connect to an OTLP metrics backend to send agent's own metrics to.
If this field is not set then the agent should assume that the settings are
unchanged.

#### own_traces

Settings to connect to an OTLP metrics backend to send agent's own traces to. If
this field is not set then the agent should assume that the settings are
unchanged.

#### own_logs

Settings to connect to an OTLP metrics backend to send agent's own logs to. If
this field is not set then the agent should assume that the settings are
unchanged.

#### other_connections

Another set of connection settings, with a string name associated with each. How
the agent uses these is agent-specific. Typically the name represents the name
of the destination to connect to (as it is known to the agent). If this field is
not set then the agent should assume that the other_connections settings are
unchanged.

### ConnectionSettings Message


ConnectionSettings describes connection settings for one destination. The
message has the following structure:


```protobuf
message ConnectionSettings {
    string destination_endpoint = 1;
    Headers headers = 2;
    string proxy_endpoint = 3;
    Headers proxy_headers = 4;
    TLSCertificate certificate = 5;
    enum Flags {
        _ = 0;
        DestinationEndpointSet = 0x01;
        ProxyEndpointSet = 0x02;
    }
    Flags flags = 6;
}
```


#### destination_endpoint


A URL, host:port or some other destination specifier.

For OpAMP destination this MUST be a HTTP or WebSocket URL and MUST be
non-empty, for example: "wss://example.com:4318/v1/opamp"

For Agent's own telemetry destination this MUST be the full HTTP URL to an
OTLP/HTTP/Protobuf receiver. The value MUST be a full URL with path and schema
and SHOULD begin with "https://", for example
"[https://example.com:4318/v1/metrics](https://example.com:4318/v1/metrics)".
The Agent MAY refuse to send the telemetry if the URL begins with "http://".

The field is considered unset if (flags & DestinationEndpointSet)==0.

#### headers


Headers to use when connecting. Typically used to set access tokens or other
authorization headers. For HTTP-based protocols the agent should set these in
the request headers.

For example:

key="Authorization", Value="Basic YWxhZGRpbjpvcGVuc2VzYW1l".

if the field is unset then the agent SHOULD continue using the headers that it
currently has (if any).

#### proxy_endpoint


A URL, host:port or some other specifier of an intermediary proxy. Empty if no
proxy is used.

Example use case: if OpAMP proxy is also an OTLP intermediary Collector then the
OpAMP proxy can direct the Agents that connect to it to also send Agents's OTLP
metrics through its OTLP metrics pipeline. Can be used for example by
OpenTelemetry Helm chart with 2 stage-collection when Agents on K8s nodes are
proxied through a standalone Collector.

For example: "https://proxy.example.com:5678"

The field is considered unset if (flags & ProxyEndpointSet)==0.

#### proxy_headers


Headers to use when connecting to a proxy. For HTTP-based protocols the agent
should set these in the request headers. If no proxy is used the Headers field
must be present and must contain no headers.

For example:

key="Proxy-Authorization", value="Basic YWxhZGRpbjpvcGVuc2VzYW1l".

if the field is unset then the agent SHOULD continue using the proxy headers
that it currently has (if any).

#### certificate


The agent should use the offered certificate to connect to the destination from
now on. If the agent is able to validate and connect using the offered
certificate the agent SHOULD forget any previous client certificates for this
connection.

This field is used to perform a client certificate revocation/rotation. if the
field is unset then the agent SHOULD continue using the certificate that it
currently has (if any).

#### flags

Bitfield of Flags enum:

```
enum Flags {
    _ = 0;
    DestinationEndpointSet = 0x01;
    ProxyEndpointSet = 0x02;
}
```


### Headers Message



```
message Headers {
    repeated Header headers = 1;
}
message Header {
    string key = 1;
    string value = 2;
}
```


### TLSCertificate Message


The message carries a TLS certificate that can be used as a client-side
certificate.

The (public_key,private_key) certificate pair should be issued and signed by a
Certificate Authority that the destination server recognizes.

Alternatively the certificate may be self-signed, assuming the server can verify
the certificate. In this case the ca_public_key field can be omitted.


```protobuf
message TLSCertificate {
    bytes public_key = 1;
    bytes private_key = 2;
    bytes ca_public_key = 3;
}
```


#### public_key


PEM-encoded public key of the certificate. Required.

#### private_key


PEM-encoded private key of the certificate. Required.

#### ca_public_key


PEM-encoded public key of the CA that signed this certificate. Optional, MUST be
specified if the certificate is CA-signed. Can be stored by intermediary
TLS-terminating proxies in order to verify the connecting client's certificate
in the future.

## Own Telemetry Reporting


Own Telemetry Reporting is an optional capability of OpAMP protocol. The Server
can offer to the Agent a destination to which the Agent can send its own
telemetry (metrics, traces or logs). If the Agent is capable of producing
telemetry and wishes to do so then it should sends its telemetry to the offered
destination using OTLP/HTTP protocol:


```
            ┌────────────┬────────┐           ┌─────────┐
            │            │ OpAMP  │  OpAMP    │ OpAMP   │
            │            │        ├──────────►│         │
            │            │ Client │           │ Server  │
            │            └────────┤           └─────────┘
            │   Agent             │
            │            ┌────────┤           ┌─────────┐
            │            │OTLP    │ OTLP/HTTP │ OTLP    │
            │            │        ├──────────►│ Metric  │
            │            │Exporter│           │ Backend │
            └────────────┴────────┘           └─────────┘
```


The Server makes the offer by sending a [ServerToAgent](#servertoagent-message)
message with a populated [connection_settings](#connection_settings) field that
contains one or more of the own_metrics, own_traces, own_logs fields set. Each
of these fields describes a destination, which can receive telemetry using OTLP
protocol.

The Server SHOULD populate the [connection_settings](#connection_settings) field
when it sends the first ServerToAgent message to the particular Agent (normally
in response to the first status report from the Agent), unless there is no OTLP
backend that can be used. The Server SHOULD also populate the field on
subsequent ServerToAgent if the destination has changed. If the destination is
unchanged the connection_settings field SHOULD NOT be set. When the Agent
receives a ServerToAgent with an unset connection_settings field the Agent SHOULD
continue sending its telemetry to the previously offered destination.

The Agent SHOULD periodically report its metrics to the destination offered in
the [own_metrics](#own_metrics) field. The recommended reporting interval is 10
seconds. Here is the diagram that shows the operation sequence:


```
                Agent                          Server
                                                            Metric
                  │                                      │  Backend
                  │ServerToAgent{ConnectionSettingsOffer}│
                  │◄─────────────────────────────────────┤    │
                  │                                      │    │
                  │                                           │
    ┌────────┐    │                                           │
    │Collect │    │                OTLP Metrics               │ ──┐
    │Own     ├───►├──────────────────────────────────────────►│   │
    │Metrics │    │                                           │   │
    └────────┘    .                    ...                    .   │ Repeats
                                                                  │
    ┌────────┐    │                                           │   │ Periodically
    │Collect │    │                OTLP Metrics               │   │
    │Own     ├───►├──────────────────────────────────────────►│   │
    │Metrics │    │                                           │ ──┘
    └────────┘    │                                           │
```


The Agent SHOULD report metrics of the agent process (or processes) and any
custom metrics that describe the agent state. Reported process metrics MUST
follow the OpenTelemetry
[conventions for processes](https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/metrics/semantic_conventions/process-metrics.md).

Similarly, the Agent SHOULD report its traces to the destination offered in the
[own_traces](#own_traces) field and logs to the destination offered in the
[own_logs](#own_logs) field.

All attributes specified in the
[identifying_attributes](#identifying_attributes) field in AgentDescription
message SHOULD be also specified in the Resource of the reported OTLP telemetry.

Attributes specified in the
[non_identifying_attributes](#non_identifying_attributes) field in
AgentDescription message may be also specified in the Resource of the reported
OTLP telemetry, in which case they SHOULD have exactly the same values.


## Configuration


Agent configuration is an optional capability of OpAMP protocol. Remote
configuration capability can be disabled if necessary (for example when using
existing configuration capabilities of an orchestration system such as
Kubernetes).

The Server can offer a Remote Configuration to the Agent by setting the
[remote_config](#remote_config) field in the ServerToAgent message. Since the
ServerToAgent message is normally sent by the Server in response to a status
report the Server has the Agent's description and may tailor the configuration
it offers to the specific Agent if necessary.

The Agent MUST set the AcceptsRemoteConfig bit of StatusReport.capabilities if
the Agent is capable of accepting remote configuration. If the bit is not set
the Server MUST not offer a remote configuration to the Agent.

The Agent's actual configuration that it uses for running may be different from
the Remote Configuration that is offered by the Server. This actual
configuration is called the Effective Configuration of the Agent. The Effective
Configuration is typically formed by the Agent after merging the Remote
Configuration with other inputs available to the Agent, e.g. a locally available
configuration.

Once the Effective Configuration is formed the Agent uses it for its operation
and will also report the Effective Configuration to the OpAMP Server via the
[effective_config](#effective_config) field of status report. The Server
typically allows the end user to see the effective configuration alongside other
data reported in the status reported by the Agent.

The Agent MUST set the ReportsEffectiveConfig bit of StatusReport.capabilities
if the Agent is capable of reporting effective configuration. If the bit is not
set the Server should not expect the StatusReport.effective_config field to be
set.

Here is the typical configuration sequence diagram:


```
               Agent                              Server

                 │ AgentToServer{StatusReport}       │   ┌─────────┐
                 ├──────────────────────────────────►├──►│ Process │
                 │                                   │   │ Status  │
Local     Remote │                                   │   │ and     │
Config    Config │ ServerToAgent{AgentRemoteConfig}  │   │ Fetch   │
  │     ┌────────┤◄──────────────────────────────────┤◄──┤ Config  │
  ▼     ▼        │                                   │   └─────────┘
┌─────────┐      │                                   │
│ Config  │      │                                   │
│ Merger  │      │                                   │
└────┬────┘      │                                   │
     │           │                                   │
     │Effective  │                                   │
     │Config     │ AgentToServer{StatusReport}       │
     └──────────►├──────────────────────────────────►│
                 │                                   │
                 │                                   │
```


Note: the Agent SHOULD NOT send a status report if the Effective Configuration
or other fields that are reported via StatusReport message are unchanged. If the
Agent does not follow this rule the operation may result in an infinite loop of
messages sent back and forth between the Agent and the Server.

The Server may also initiate sending of a remote configuration on its own,
without waiting for a status report from the Agent. This can be used to
re-configure an Agent that is connected but which has nothing new to report. The
sequence diagram in this case looks like this:


```
               Agent                              Server

                 │                                   │
                 │                                   │
                 │                                   │   ┌────────┐
Local     Remote │                                   │   │Initiate│
Config    Config │  ServerToAgent{AgentRemoteConfig} │   │and     │
  │     ┌────────┤◄──────────────────────────────────┤◄──┤Send    │
  ▼     ▼        │                                   │   │Config  │
┌─────────┐      │                                   │   └────────┘
│ Config  │      │                                   │
│ Merger  │      │                                   │
└────┬────┘      │                                   │
     │           │                                   │
     │Effective  │                                   │
     │Config     │ AgentToServer{StatusReport}       │
     └──────────►├──────────────────────────────────►│
                 │                                   │
                 │                                   │
```


The Agent may ignore the Remote Configuration offer if it does not want its
configuration to be remotely controlled by the Server.

### Configuration Files


The configuration of the Agent is a collection of named configuration files
(this applies both to the Remote Configuration and to the Effective
Configuration).

The file names MUST be unique within the collection. It is possible that the
Remote and Local Configuration MAY contain a file with the same name but with a
different content. How these files are merged to form an Effective Configuration
is agent type-specific and is not part of the OpAMP protocol.

If there is only one configuration file in the collection then the file name MAY
be empty.

The collection of configuration files is represented using a AgentConfigMap
message:


```protobuf
message AgentConfigMap {
  map<string, AgentConfigFile> config_map = 1;
}
```


The config_map field of the AgentConfigSet message is a map of configuration
files, where keys are file names.

For agents that use a single config file the config_map field SHOULD contain a
single entry and the key MAY be an empty string.

The AgentConfigFile message represents one configuration file and has the
following structure:


```protobuf
message AgentConfigFile {
  bytes body = 1;
  string content_type = 2;
}
```


The body field contains the raw bytes of the configuration file. The content,
format and encoding of the raw bytes is agent type-specific and is outside the
concerns of OpAMP protocol.

content_type is an optional field. It is a MIME Content-Type that describes
what's contained in the body field, for example "text/yaml". The content_type
reported in the Effective Configuration in the Agent's status report may be used
for example by the Server to visualize the reported configuration nicely in a
UI.

### Security Considerations


Remote Configuration is a potentially dangerous functionality that may be
exploited by malicious actors. For example if the Agent is capable of collecting
local files and sending over the network then a compromised OpAMP Server may
offer a malicious remote configuration to the Agent and compel the Agent to
collect a sensitive local file and send to a specific network destination.

See Security section for [general recommendations](#general-recommendations) and
recommendations specifically for
[remote reconfiguration](#configuration-restrictions) capabilities.

### AgentRemoteConfig Message


The message has the following structure:


```protobuf
message AgentRemoteConfig {
  AgentConfigMap config = 1;
}
```


## Packages

Each Agent is composed of one or more packages. A package has a name and content stored
in a file. The content of the file, functionality provided by the packages, how they are
stored and used by the Agent  side is agent type-specific and is outside the concerns of
the OpAMP protocol.

There are two types of packages: top-level and sub-packages.

There is normally only one top-level package, which implements the primary
functionality of the Agent. When there is only one top-level package it may have an
empty name.

Sub-packages are also known as addons or plugins. The sub-packages can be installed at
the Agent for added functionality (hence the name addons). 

The Agent may have one or more packages installed. Each package has a name. The
Agent cannot have more than one package of the particular name installed.

Different package may have files with the same name, file names are not globally
unique, they are only unique within the scope of a particular package.

Package may be provided and installed locally (e.g. by a local user). The packages
may be also offered to the Agent remotely by the Server, in which case the Agent
may download and install the packages.

To offer packages to the Agent the Server sets the
[packages_available](#packages_available) field in the ServerToAgent message that
is sent either in response to a status report form the Agent or by Server's
initiative if the Server wants to push packages to the Agent.

The [PackagesAvailable](#packagesavailable-message) message describes the packages
that are available on the Server for this Agent. For each package the message
describes the file that has the package's content and provides the URL from which
the file can be downloaded using an HTTP GET request. The URLs point to package
files on a Download Server (which may be on the same host as the OpAMP Server or
a different host).

The protocol supports only a single downloadable file per package. If the Agent's
packages conceptually are composed of multiple files then the Agent and Server can
agree to store the files in any file format that allows storing multiple files
in a single file, e.g. a zip or tar file. After downloading the single package
file the Agent may extract the files contained in it. How exactly this is done
is Agent specific and is beyond the scope of the protocol.

The Server is allowed to make a package offer only if the Agent indicated that it
can accept packages via AcceptsPackages bit of StatusReport.capabilities field.

### Downloading Packages


After receiving the [PackagesAvailable](#packagesavailable-message) message the
Agent SHOULD follow this download procedure:

#### Step 1


Compare the aggregate hash of all packages it has with the aggregate hash offered
by the Server in the all_packages_hash field.

If the aggregate hash is the same then consider the download procedure done,
since it means all packages on the Agent are the same as offered by the Server.
Otherwise, go to Step 2.

#### Step 2


For each package offered by the Server the Agent SHOULD check if it should
download the particular package:



* If the Agent does not have a package with the specified name then it SHOULD
  download the package. See Step 3 on how to download each package file.
* If the Agent has the package the Agent SHOULD compare the hash of the package that
  the Agent has with the hash of the package offered by the Server in the
  [hash](#hash) field in the [PackageAvailable](#packageavailable-message) message.
  If the hashes are the same then the package is the same and processing for this
  package is done, proceed to the next package. If the hashes are different then
  check the package file as described in Step 3.

Finally, if the Agent has any packages that are not offered by the Server the
packages SHOULD be deleted by the Agent.

#### Step 3

For the file of the package offered by the Server the Agent SHOULD check if it
should download the file:

* If the Agent does not have a file with the specified name then it SHOULD
  download the file.
* If the Agent has the file then the Agent SHOULD compare the hash of the file
  it has locally with the [hash](#hash) field in the
  [DownloadableFile](#downloadablefile-message) message. If hashes are the same
  the processing of this file is done. Otherwise, the offered file is different
  and the file SHOULD be downloaded from the location specified in the
  [download_url](#download_url) field of the
  [DownloadableFile](#downloadablefile-message) message. The Agent SHOULD use an
  HTTP GET message to download the file.

The procedure outlined above allows the Agent to efficiently download only new
or changed packages and only download new or changed files.

After downloading the packages the Agent can perform any additional processing
that is agent type-specific (e.g. "install" or "activate" the packages in any way
that is specific to the agent).

### Package Status Reporting


During the downloading and installation process the Agent MAY periodically
report the status of the process. To do this the Agent SHOULD send an
[AgentToServer](#agenttoserver-message) message and set the
[package_statuses](#packagestatuses-message) field accordingly.

Once the downloading and installation of all packages is done (succeeded or
failed) the Agent SHOULD report the status of all packages to the Server.

Here is the typical sequence diagram for the package downloading and status
reporting process:


```
    Download           Agent                             OpAMP
     Server                                              Server
       │                 │                                  │
       │                 │  ServerToAgent{PackagesAvailable}│
       │                 │◄─────────────────────────────────┤
       │   HTTP GET      │                                  │
       │◄────────────────┤                                  │
       │ Download file #1│                                  │
       ├────────────────►│                                  │
       │                 │ AgentToServer{PackageStatuses}   │
       │                 ├─────────────────────────────────►│
       │   HTTP GET      │                                  │
       │◄────────────────┤                                  │
       │ Download file #2│                                  │
       ├────────────────►│                                  │
       │                 │ AgentToServer{StatusReport}      │
       │                 ├─────────────────────────────────►│
       │                 │                                  │
       .                 .                                  .

       │   HTTP GET      │                                  │
       │◄────────────────┤                                  │
       │ Download file #N│                                  │
       ├────────────────►│                                  │
       │                 │ AgentToServer{PackageStatuses}   │
       │                 ├─────────────────────────────────►│
       │                 │                                  │
```


The Agent MUST always include all packages it has or is processing (downloading or
installing) in PackageStatuses message.

Note that the Agent MAY also report the status of packages it has installed
locally, not only the packages it was offered and downloaded from the Server.
[TODO: is this necessary?]

### Calculating Hashes


The Agent and the Server use hashes to identify content of files and packages such
that the Agent can decide what files and packages need to be downloaded.

The calculation of the hashes is performed by the Server. The server MUST choose
a strong hash calculation method with minimal collision probability (and it may
seed random values into calculation to guarantee hash uniqueness if such
guarantees are needed by the implementation).

The hashes are opaque to the Agent, the Agent never calculates hashes, it only
stores and compares them.

There are 3 levels of hashes: 

#### File Hash

The hash of the packages file content. This is stored in the [content_hash](#content_hash) field in
the [DownloadableFile](#downloadablefile-message) message. This value SHOULD be
used by the Agent to determine if the particular file it has is different on the
Server and needs to be re-downloaded.

#### Package Hash

The package hash that identifies the entire package (package name and file content).
This hash is stored in the [hash](#hash) field in the
[PackageAvailable](#packageavailable-message) message.

This value SHOULD be used by the Agent to determine if the particular package it
has is different on the Server and needs to be re-downloaded.

#### All Packages Hash


The all packages hash is the aggregate hash of all packages for the particular
Agent. The hash is calculated as an aggregate of all package names and content.
This hash is stored in the [all_packages_hash](#all_packages_hash) field in the
[PackagesAvailable](#packagesavailable-message) message.

This value SHOULD be used by the Agent to determine if any of the packages it has
are different from the ones available on the Server and need to be
re-downloaded.

Note that the aggregate hash does not include the packages that are available on
the Agent locally and were not downloaded from the download server.

### Security Considerations


Downloading packages remotely is a potentially dangerous functionality that may be
exploited by malicious actors. If packages contain executable code then a
compromised OpAMP Server may offer a malicious package to the Agent and compel the
Agent to execute arbitrary code.

See Security section for [general recommendations](#general-recommendations) and
recommendations specifically for [code signing](#code-signing) capabilities.

### PackagesAvailable Message

The message has the following structure:

```
message PackagesAvailable {
    map<string, PackageAvailable> packages = 1;
    bytes all_packages_hash = 2;
}
```

#### packages

A map of packages. Keys are package names.

#### all_packages_hash

Aggregate hash of all remotely installed packages.

The agent SHOULD include this value in subsequent
[StatusReport](#statusreport-message) messages. This in turn allows the Server
to identify that a different set of packages is available for the agent and
specify the available packages in the next DataToAgent message.

This field MUST be always set if the Server supports sending packages to the agents
and if the Agent indicated it is capable of accepting packages.

### PackageAvailable Message

This message is an offer from the Server to the agent to install a new package or
initiate an upgrade or downgrade of a package that the Agent already has. The
message has the following structure:

```protobuf
message PackageAvailable {
    PackageType type = 1;
    string version = 2;
    DownloadableFile file = 3;
    bytes hash = 4;
}
```

TODO: do we need other fields, e.g. description?

#### type

The type of the package, either an addon or a top-level package.

```protobuf
enum PackageType {
    TopLevelPackage = 0;
    AddonPackage    = 1;
}
```

#### version

The package version that is available on the server side. The agent may for
example use this information to avoid downloading a package that was previously
already downloaded and failed to install.

#### file

The downloadable file of the package.

#### hash

The hash of the package. SHOULD be calculated based on all other fields of the 
PackageAvailable message and content of the file of the package. The hash is used by
the Agent to determine if the package it has is different from the package the Server
is offering.

### DownloadableFile Message

The message has the following structure:

```protobuf
message DownloadableFile {
    string download_url = 1;
    bytes content_hash = 2;
    bytes signature = 3;
}
```

#### download_url

The URL from which the file can be downloaded using HTTP GET request. The server
at the specified URL SHOULD support range requests to allow for resuming
downloads.

#### content_hash

The SHA256 hash of the file content. Can be used by the Agent to verify that the file
was downloaded correctly.

#### signature

Optional signature of the file content. Can be used by the Agent to verify the
authenticity of the downloaded file, for example can be the 
[detached GPG signature](https://www.gnupg.org/gph/en/manual/x135.html#AEN160).
The exact signing and verification method is Agent specific. See 
[Code Signing](#code-signing) for recommendations.

# Connection Management


## Establishing Connection

The Agent connects to the Server by establishing an HTTP(S) connection.

If WebSocket transport is used then the connection is upgraded to WebSocket as
defined by WebSocket standard.

After the connection is established the Agent MUST send the first
[status report](#status-reporting) and expect a response to it.

If the Agent is unable to establish a connection to the Server it SHOULD retry
connection attempts and use exponential backoff strategy with jitter to avoid
overwhelming the Server.

When retrying connection attempts the Agent SHOULD honour any
[throttling](#throttling) responses it receives from the Server.

## Closing Connection

### WebSocket Transport, Agent Initiated

To close a connection the Agent MUST first send an AgentToServer message with
agent_disconnect field set. The Agent MUST then send a WebSocket
[Close](https://datatracker.ietf.org/doc/html/rfc6455#section-5.5.1) control
frame and follow the procedure defined by WebSocket standard.

### WebSocket Transport, Server Initiated

To close a connection the Server MUST then send a WebSocket
[Close](https://datatracker.ietf.org/doc/html/rfc6455#section-5.5.1) control
frame and follow the procedure defined by WebSocket standard.

### Plain HTTP Transport

The Agent is considered logically disconnected as soon as the OpAMP HTTP
response is completed. It is not necessary for the Agent to send AgentToServer
message with agent_disconnect field set since it is always implied anyway that
the Agent is gone after the HTTP response is completed.

HTTP keep-alive may be used by the Agent and the Server but it has no effect on
the logical operation of the OpAMP protocol.

The Server may use its own business logic to decide what it considers an active
Agent (e.g. an Agent that continuously polls) vs an inactive Agent (e.g. an
Agent that has no made an HTTP for a specific period of time). This business
logic is outside the scope of OpAMP specification.

## Restoring WebSocket Connection

If an established WebSocket connection is broken (disconnected) unexpectedly the
Agent SHOULD immediately try to re-connect. If the re-connection fails the Agent
SHOULD continue connection attempts with backoff as described in
[Establishing Connection](#establishing-connection).


## Duplicate WebSocket Connections

Each Agent instance SHOULD connect no more than once to the Server. If the Agent
needs to re-connect to the Server the Agent MUST ensure that it sends an
AgentDisconnect message first, then closes the existing connection and only then
attempts to connect again.

The Server MAY disconnect or deny serving requests if it detects that the same
Agent instance has more than one simultaneous connection or if multiple Agent
instances are using the same instance_uid.

The Server SHOULD detect duplicate instance_uids (which may happen for example
when Agents are using bad UID generators or due to cloning of the VMs where the
Agent runs). When a duplicate instance_uid is detected, Server SHOULD generate
a new instance_uid, and send it as new_instance_uid value of AgentIdentification.

## Authentication


The Agent and the Server MAY use authentication methods supported by HTTP, such
as [Basic](https://datatracker.ietf.org/doc/html/rfc7617) authentication or
[Bearer](https://datatracker.ietf.org/doc/html/rfc6750) authentication. The
authentication happens when the HTTP connection is established before it is
upgraded to a WebSocket connection.

The Server MUST respond with
[401 Unauthorized](https://datatracker.ietf.org/doc/html/rfc7235#section-3.1) if
the Agent authentication fails.

## Bad Request


If the Server receives a malformed AgentToServer message the Server SHOULD
respond with a ServerToAgent message with [error_response](#errorresponse-message)
set accordingly. The [type](#type) field MUST be set to BAD_REQUEST and
[error_message](#error_message) SHOULD be a human readable description of the
problem with the AgentToServer message.

The Agent SHOULD NOT retry sending an AgentToServer message to which it received
a BAD_REQUEST response.

## Retrying Messages


The Agent MAY retry sending AgentToServer message if:


* AgentToServer message that requires a response was sent, however no response
  was received within a reasonable time (the timeout MAY be configurable).
* AgentToServer message that requires a response was sent, however the
  connection was lost before the response was received.
* After receiving an UNAVAILABLE response from the Server as described in the
  [Throttling](#throttling) section.

For messages that require a response if the Server receives the same message
more than once the Server MUST respond to each message, not just the first
message, even if the Server detects the duplicates and processes the message
once.

Note that the Agent is not required to keep a growing queue of messages that it
wants to send to the Server if the connection is unavailable. The Agent
typically only needs to keep one up-to-date message of each kind that it wants
to send to the Server and send it as soon as the connection is available.

For example, the Agent should keep track of its own status and compose a
StatusReport message that is ready to be sent at the first opportunity. If the
Agent is unable to send the StatusReport message (for example if the connection
is not yet available) the Agent does not need to create a new StatusReport every
time the Agent's status changes and keep all these StatusReport messages in a
queue ready to be sent. The Agent simply needs to keep one up-to-date
StatusReport message and send it at the first opportunity. This of course
requires the StatusReport message to contain all changes since it was last
reported and to correctly reflect the current (last) state of the Agent.

Similarly, all other Agent reporting capabilities, such as Addon Status
Reporting or Agent Package Installation Status Reporting require the Agent to
only keep one up-to-date status message and send it at the earliest opportunity.

The exact same logic is true in the opposite direction: the Server normally only
needs to keep one up-to-date message of a particular kind that it wants to
deliver to the Agent and send it as soon as the connection to the Agent is
available.


## Throttling

### WebSocket Transport

When the Server is overloaded and is unstable to process the AgentToServer
message it SHOULD respond with an ServerToAgent message, where
[error_response](#servererrorresponse-message) is filled with [type](#type) field
set to UNAVAILABLE.
~~The agent SHOULD retry the message.~~ _(Note: retrying individual messages is
not possible since we no longer have sequence ids and don't know which message
failed)._ The agent SHOULD disconnect, wait, then reconnect again and resume its
operation. The retry_info field may be optionally set with
retry_after_nanoseconds field specifying how long the Agent SHOULD wait before
~~retiring the message~~ reconnecting:


```protobuf
message RetryInfo {
    uint64 retry_after_nanoseconds = 1;
}
```


If retry_info is not set then the Agent SHOULD implement an exponential backoff
strategy to gradually increase the interval between retries.

### Plain HTTP Transport

In the case when plain HTTP transport is used as well as when WebSocket is used
and the Server is overloaded and is unable to upgrade the HTTP connection to
WebSocket the Server MAY return
[HTTP 503 Service Unavailable](https://datatracker.ietf.org/doc/html/rfc7231#page-63)
or
[HTTP 429 Too Many Requests](https://datatracker.ietf.org/doc/html/rfc6585#section-4)
response and MAY optionally set
[Retry-After](https://datatracker.ietf.org/doc/html/rfc7231#section-7.1.3)
header to indicate when SHOULD the Agent attempt to reconnect. The Agent SHOULD
honour the corresponding requirements of HTTP specification.

The minimum recommended retry interval is 30 seconds.

# Security


Remote configuration, downloadable packages are a significant
security risk. By sending a malicious server-side configuration or a malicious
package the Server may compel the Agent to perform undesirable work. This section
defines recommendations that reduce the security risks for the Agent.

Guidelines in this section are optional for implementation, but are highly
recommended for sensitive applications.

## General Recommendations


We recommend that the Agent employs the zero-trust security model and does not
automatically trust the remote configuration or other offers it receives from
the Server. The data received from the Server SHOULD be verified and sanitized
by the Agent in order to limit and prevent the damage that may be caused by
malicious actors. We recommend the following:



* The Agent SHOULD run at the minimum possible privilege to prevent itself from
  accessing sensitive files or perform high privilege operations. The Agent
  SHOULD NOT run as root user, otherwise a compromised Agent may result in total
  control of the machine by malicious actors.
* If the Agent is capable of collecting local data it SHOULD limit the
  collection to a specific set of directories. This limitation SHOULD be locally
  specified and SHOULD NOT be overridable via remote configuration. If this rule
  is not followed the remote configuration functionality may be exploited to
  access sensitive information on the Agent's machine.
* If the Agent is capable of executing external code located on the machine
  where it runs and this functionality can be specified in the Agent's
  configuration then the Agent SHOULD limit such functionality only to specific
  scripts located in a limited set of directories. This limitation SHOULD be
  locally specified and SHOULD NOT be overridable via remote configuration. If
  this rule is not followed the remote configuration functionality may be
  exploited to perform arbitrary code execution on the Agent's machine.

## Configuration Restrictions


The Agent is recommended to restrict what it may be compelled to do via remote
configuration.

Particularly, if it is possible via a configuration to ask the Agent to collect
data from the machine it runs on (as it is often the case for telemetry
collecting agents) then we recommend to have agent-side restrictions as to what
directories or files the Agent is allowed to collect. Upon receiving a remote
config the Agent must validate the configuration against the list of
restrictions and refuse to apply the configuration either fully or partially if
it violates the restrictions or sanitize the configuration such that it does not
collect data from prohibited directories or files.

Similarly, if the configuration provides means to order the Agent to execute
processes or scripts on the machine it runs on we recommend to have agent-side
restrictions as to what executable files from what directories the Agent is
allowed to run.

It is recommended that the restrictions are specified in the form of "allow
list" instead of the "deny list". The restrictions may be hard-coded or may be
end-user definable in a local config file. It should not be possible to override
these restrictions by sending a remote config from the Server to the agent.

## Opt-in Remote Configuration


It is recommended that remote configuration capabilities are not enabled in the
Agent by default. The capabilities should be opt-in by the user.

## Code Signing


Any executable code that is part of a package should be signed
to prevent a compromised Server from delivering malicious code to the Agent. We
recommend the following:



* Any downloadable executable code (e.g. executable packages)
  need to be code-signed. The actual code-signing and verification mechanism is
  agent specific and is outside the concerns of the OpAMP specification.
* The Agent SHOULD verify executable code in downloaded files to ensure the code
  signature is valid.
* The downloadable code can be signed with the signature included in the file content or 
  have a detached signature recorded in the DownloadableFile
  message's [signature](#signature) field. Detached signatures may be used for example
  with [GPG signing](https://www.gnupg.org/gph/en/manual/x135.html#AEN160).
* If Certificate Authority is used for code signing it is recommended that the
  Certificate Authority and its private key is not co-located with the OpAMP
  Server, so that a compromised Server cannot sign malicious code.
* The Agent SHOULD run any downloaded executable code (the packages and or any
  code that it runs as external processes) at the minimum possible privilege to
  prevent the code from accessing sensitive files or perform high privilege
  operations. The Agent SHOULD NOT run downloaded code as root user.

# Interoperability

## Interoperability of Partial Implementations

OpAMP defines a number of capabilities for the Agent and the Server. Most of
these capabilities are optional. The Agent or the Server should be prepared that
the peer does not support a particular capability.

Both the Agent and the Server indicate the capabilities that they support during
the initial message exchange. The Agent sets the capabilities bit-field in the
StatusReport message, the Server sets the capabilities bit-field in the
ServerToAgent message.

Each set bit in the capabilities field indicates that the particular capability
is supported. The list of Agent capabilities is [here](#statusreport-message).
The list of Server capabilities is [here](#servertoagent-message).

After the Server learns about the capabilities of the particular Agent the
Server MUST stop using the capabilities that the Agent does not support.

Similarly, after the Agent learns about the capabilities of the Server the Agent
MUST stop using the capabilities that the Server does not support.

The specifics of what in the behavior of the Agent and the Server needs to
change when they detect that the peer does not support a particular capability
are described in this document where relevant.

## Interoperability of Future Capabilities

There are 2 ways OpAMP enables interoperability between an implementation of the
current version of this specification and an implementation of a future,
extended version of OpAMP that adds more capabilities that are not described in
this specification.

### Ignorable Capability Extensions

For the new capabilities that extend the functionality in such a manner that
they can be silently ignored by the peer a new field may be added to any
Protobuf message. The sender that implements this new capability will set the
new field. A recipient that implements an older version of the specification
that is unaware of the new capability will simply ignore the new field. The
Protobuf encoding ensures that the rest of the fields are still successfully
deserialized by the recipient.

### Non-Ignorable Capability Extensions 

For the new capabilities that extend the functionality in such a manner that
they cannot be silently ignored by the peer a different approach is used.

The capabilities fields in StatusReport and ServerToAgent messages contains a
number of reserved bits. These bits SHOULD be used for indicating support of new
capabilities that will be added to OpAMP in the future.

The Agent and the Server MUST set these reserved bits to 0 when sending the
message. This allows the recipient, which implements a newer version of OpAMP to
learn that the sender does not support the new capability and adjust its
behavior correspondingly.

The StatusReport and ServerToAgent messages are the first messages exchanged by
the Agent and Server which allows them to learn about the capabilities of the
peer and adjust their behavior appropriately. How exactly the behavior is
adjusted for future capabilities MUST be defined in the future specification of
the new capabilities.

# Performance and Scale


TBD

# Open Questions




* How does the server know that the request/report received actually is
  generated by the agent that the message claims? Do we need to verify that the
  message is not fake (impersonated) or the server trusts the senders that are
  authenticated?
* ~~In Otel Helm chart how are Agents on k8s nodes and the standalone Collector
  are managed? Do we consider the entire Otel Helm chart to be a single Agent or
  each individual instance on each node plus the standalone Collector are
  separate Agents from management perspective?~~ Discussed with Dmitry and
  concluded that each need to be separate agent instances.
* Do we need to define OpenTelemetry semantic conventions for reporting typical
  collection Agent-specific metrics (e.g. input/processing/output data rates,
  throughput, latency, etc)?
* ~~Do we need a capability for the Server to order the Agent to restart?~~ Added.
* Do we need Agent-initiated client certificate rotation capability (in addition
  to Server-initiated that we already have)?
* Do we need to recommend the Agent to cache the remote config and OTLP metric
  destination locally in case the Server is unavailable to make the system more
  resilient?
* ~~Do we need to make initial (first time after connection) configuration
  fetching more efficient if it is unchanged since it was fetched during the
  previous connection session (by exchanging config hashes first)? May be
  important if remote configuration can be very large and/or Agents reconnect
  frequently. If using hashes should this be one aggregate hash per config file
  collection or individual hashes per config file?~~ Done.
* ~~Do we need the sequence_num concept?~~ Deleted for now, not necessary for
  current feature set, but may need to be restored for other features (e.g.
  custom "extensions").
* ~~Does the Server need to actively detect duplicate instance_uids, which may
  happen due to Agents using bad UID generators which create globally non-unique
  UIDs?~~ Added.
* ~~Do we need to split the AddonStatus and AgentStatus from the general
  StatusReport?~~ Yes, splitted.
* Does WebSocket frame compression work for us or do we need our own mechanism?
* What are server CPU/RAM, network resources requirements and intermediary
  capabilities requirements at scale (millions of agents)? Test and fill the
  blanks in the [Performance and Scale](#performance-and-scale) section.
* How does TLS work with cloud provider load balancers? Do we terminate TLS at
  load balancer and if yes how does the server know the client's certificate for
  acceptance or to rotate? Add section on Load Balancing to explain cons and
  pros of TLS-terminating vs non-terminating load balancers (client certificate
  invisible to the server when TLS-terminating).
* ~~Do we need to add log and trace destinations?~~ Added.
* ~~Do we need access token rotation? Use the initial token and generate on the
  first connection.~~ Added.
* ~~Can we unite certificate offer and access token offer?~~ Unified.
* ~~Can we have multiple offers of OTHER type?~~ Now using named "other"
  connections.
* ~~Do we need connection status reporting or it can be deleted?~~ Deleted.
* Do we need to allow for "extensions" to the protocol so that custom messages
  may be exchanged between the Agent and the Server in the same WebSocket
  connection?

# FAQ for Reviewers


### What is WebSocket?


WebSocket is a bidirectional, message-oriented protocol that uses plain HTTP for
establishing the connection and then uses the HTTP's existing TCP connection to
deliver messages. It has been an
[RFC](https://datatracker.ietf.org/doc/html/rfc6455) standard for a decade now.
It is widely supported by browsers, servers, proxies and load balancers, has
libraries in virtually all popular programming languages, is supported by
network inspection and debugging tools, is secure and efficient and provides the
exact message-oriented semantics that we need for OpAMP.

### Why not Use TCP Instead of WebSocket?


We could roll out our own message-oriented implementation over TCP but there are
no benefits over WebSocket which is an existing widely supported standard. A
custom TCP-based solution would be more work to design, more work to implement
and more work to troubleshoot since existing network tools would not recognize
it.

### Why not alwaysUse HTTP Instead of WebSocket?

Regular HTTP is a half-duplex protocol, which makes delivery of messages from
the server to the client tied to the request time of the client. This means that
if the server needs to send a message to the client the client either needs to
periodically poll the server to give the server an opportunity to send a message
or we should use something like long polling.

Periodic polling is expensive. OpAMP protocol is largely idle after the initial
connection since there is typically no data to deliver for hours or days. To
have a reasonable delivery latency the client would need to poll every few
seconds and that would significantly increase the costs on the server side (we
aim to support many millions simultaneous of Agents, which would mean servicing
millions of polling requests per second).

Long polling is more complicated to use than WebSocket since it only provides
one-way communication, from the server to the client and necessitates the second
connection for client-to-server delivery direction. The dual connection needed
for a long polling approach would make the protocol more complicated to design
and implement without much gains compared to WebSocket approach.

### Why not Use gRPC Instead of WebSocket?


gRPC is a big dependency that some implementations are reluctant to take. gRPC
requires HTTP/2 support from all intermediaries and is not supported in some
load balancers. As opposed to that, WebSocket is usually a small library in most
language implementations (or is even built into runtime, like it is in browsers)
and is more widely supported by load balancers since it is based on HTTP/1.1
transport.

Feature-wise gRPC streaming would provide essentially the same functionality as
WebSocket messages, but it is a more complicated dependency that has extra
requirements with no additional benefits for our use case (benefits of gRPC like
ability to multiplex multiple streams over one connection are of no use to
OpAMP).

# Future Possibilities


Define specification for Concentrating Proxy that can serve as intermediary to
reduce the number of connections to the Server when a very large number
(millions and more) of Agents are managed.

OpAMP may be extended by a polling-based HTTP standard. It will have somewhat
worse latency characteristics but may be desirable for some implementation.

# References


## Agent Management




* Splunk
  [Deployment Server](https://docs.splunk.com/Documentation/Splunk/8.2.2/Updating/Aboutdeploymentserver).
* Centralized Configuration of vRealize
  [Log Insight Agents](https://docs.vmware.com/en/vRealize-Log-Insight/8.4/com.vmware.log-insight.agent.admin.doc/GUID-40C13E10-1554-4F1B-B832-69CEBF85E7A0.html).
* Google Cloud
  [Guest Agent](https://github.com/GoogleCloudPlatform/guest-agent) uses HTTP
  [long polling](https://cloud.google.com/compute/docs/metadata/querying-metadata#waitforchange).

## Configuration Management




* [Uber Flipr](https://eng.uber.com/flipr/).
* Facebook's
  [Holistic Configuration Management](https://research.fb.com/wp-content/uploads/2016/11/holistic-configuration-management-at-facebook.pdfhttps://research.fb.com/wp-content/uploads/2016/11/holistic-configuration-management-at-facebook.pdf)
  (push).

## Security and Certificate Management




* mTLS in Go:
  [https://kofo.dev/how-to-mtls-in-golang](https://kofo.dev/how-to-mtls-in-golang)
* e2e audit
  [https://pwn.recipes/posts/roll-your-own-e2ee-protocol/](https://pwn.recipes/posts/roll-your-own-e2ee-protocol/)
* ACME certificate management protocol
  [https://datatracker.ietf.org/doc/html/rfc8555](https://datatracker.ietf.org/doc/html/rfc8555)
* ACME for client certificates
  [http://www.watersprings.org/pub/id/draft-moriarty-acme-client-01.html](http://www.watersprings.org/pub/id/draft-moriarty-acme-client-01.html)

## Cloud Provider Support




* AWS:
  [https://aws.amazon.com/elasticloadbalancing/features/](https://aws.amazon.com/elasticloadbalancing/features/)
* GCP:
  [https://cloud.google.com/appengine/docs/flexible/go/using-websockets-and-session-affinity](https://cloud.google.com/appengine/docs/flexible/go/using-websockets-and-session-affinity)
* Azure:
  [https://docs.microsoft.com/en-us/azure/application-gateway/application-gateway-websocket](https://docs.microsoft.com/en-us/azure/application-gateway/application-gateway-websocket)

## Other




* [Websocket Load Balancing](https://pdf.sciencedirectassets.com/280203/1-s2.0-S1877050919X0006X/1-s2.0-S1877050919303576/main.pdf?X-Amz-Security-Token=IQoJb3JpZ2luX2VjEI3%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FwEaCXVzLWVhc3QtMSJHMEUCIAhC7%2Bztk8aH29lDsWYFIHLt97kwOE4PoWkiPfH2OTQwAiEA65oLMq1RhzF6b5pSixhnPVLT9G2iKkG145XtdpW4d4IqgwQIpv%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FARAEGgwwNTkwMDM1NDY4NjUiDDtEVrp4vXmh0hvwWyrXAxnfLN4%2BsMMF7wxoXOiBFQjn%2FJLpSLUIWghc87%2Bx2tbvdCIC%2BQV4JCY9rOK3p9rogqh9yoI2yem4SHASzL%2BQUQMOiGWagk%2FzyCNdS0y%2FLzHkKDahvRMJGKxWeXErbsuvPCufnbDpNHmKD0vnT5sqpOoM64%2FJVxvd9QYx48xasNMtXZ8%2BFm9wPpNQnsWSEZKYiOKLaLfnATzcXADJmOCTVQbwZoT4%2BFKWcoujBxSBHE9kw7S749ywQ9bOtgNWid5R2dj0z%2Br6C63SnBS3IdMSZ2qO4H3XTYY5pbfNCfR57zKIdwyp3zLJr5%2BtTEz1YR9FXwWF9niDEr0v2qu%2FlL7%2BGHsak8UQ4hZ0BFlZtcIRNW1lpZd9bNSINb3d6MnGeYrkhxQVP0KcZsowP9672IYzuMD4nK1X4Hv7bMqeO7ojuSf%2F2ND9NXn0Ldr%2BX0lzESv10LyhElCGfFJ4EZjIxYOKZdee1Zc1USdj1kNx1OC0cefIN1ixiA0OIbtWVz1lI6n1LYpngeUYngGP0ZFb%2Br%2FbleC3WarDHWIn4NNjI1aQW3P9fTmKEan3b3skRIBbwM8%2FrwRJGYQ03JaCKuU4xbogz9uEL%2BbpJ1SB7En8pS8xuSiE1kzvnsF0FTCEvMSIBjqlAadtZOgWRUk2FxdoYsCK43DYqD6zjbDrRBfyIXTJGlJYKt5iR3SCi8ySacO1aPZhah9ir179nYi5dVYnf5c6%2Fe8Q5Mo1uRtisouWJZSjAOhmRY7a76fSqyHwj088aI5t1pcempNCOnsM4SfyrZJ9UE%2FKfb5YsJ71VwRPZ%2BXZ%2FvZnQlW7e6NJqWswhre0pQftkShN%2BbpE%2FTzusekzm6q3w6b3ynUN8A%3D%3D&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20210809T134614Z&X-Amz-SignedHeaders=host&X-Amz-Expires=299&X-Amz-Credential=ASIAQ3PHCVTY2T5F5OYZ%2F20210809%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Signature=6098b604ebac38723d26ae66e527b397312a6371ad19e1a4fbfe94ca9c61e1a9&hash=ebd5b943d3aff77c6bfb8853fab1598db53996f5f018d688364a41dd71c15d92&host=68042c943591013ac2b2430a89b270f6af2c76d8dfd086a07176afe7c76c2c61&pii=S1877050919303576&tid=spdf-3c0a3a1a-bd3b-40d0-af0d-48a46859c89a&sid=d21b79c59bbb0348b79945c084cc3b66983agxrqa&type=client)

--

Copyright The OpenTelemetry Authors

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
