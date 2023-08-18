# FAQ about OpAMP specification

## What is WebSocket?

WebSocket is a bidirectional, message-oriented protocol that uses plain HTTP for
establishing the connection and then uses the HTTP's existing TCP connection to
deliver messages. It has been an
[RFC](https://datatracker.ietf.org/doc/html/rfc6455) standard for a decade now.
It is widely supported by browsers, servers, proxies and load balancers, has
libraries in virtually all popular programming languages, is supported by
network inspection and debugging tools, is secure and efficient and provides the
exact message-oriented semantics that we need for OpAMP.

## Why not Use TCP Instead of WebSocket?

We could roll out our own message-oriented implementation over TCP but there are
no benefits over WebSocket which is an existing widely supported standard. A
custom TCP-based solution would be more work to design, more work to implement
and more work to troubleshoot since existing network tools would not recognize
it.

## Why not alwaysUse HTTP Instead of WebSocket?

Regular HTTP is a half-duplex protocol, which makes delivery of messages from
the Server to the client tied to the request time of the client. This means that
if the Server needs to send a message to the client the client either needs to
periodically poll the Server to give the Server an opportunity to send a message
or we should use something like long polling.

Periodic polling is expensive. OpAMP protocol is largely idle after the initial
connection since there is typically no data to deliver for hours or days. To
have a reasonable delivery latency the client would need to poll every few
seconds and that would significantly increase the costs on the Server side (we
aim to support many millions simultaneous of Agents, which would mean servicing
millions of polling requests per second).

Long polling is more complicated to use than WebSocket since it only provides
one-way communication, from the Server to the client and necessitates the second
connection for client-to-Server delivery direction. The dual connection needed
for a long polling approach would make the protocol more complicated to design
and implement without much gains compared to WebSocket approach.

## Why not Use gRPC Instead of WebSocket?

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
