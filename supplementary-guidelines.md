# Message Attestation: Supplementary Guidelines

This document provides non-normative guidance for implementors and operators
deploying Message Attestation. It is a companion to the normative
[specification](specification.md).

## Motivation

OpAMP servers necessarily occupy a high-exposure position on the network: they
must be reachable by every member of the fleet. A compromise of the OpAMP server
(or a TLS-terminating proxy in front of it) would, without Message Attestation,
yield full control over all connected Agents.

Message Attestation addresses this by separating the *distribution* of messages
from the *authorization* of messages. The distribution server remains at the
network edge; the signing authority lives deeper in the infrastructure, away
from the attack surface.

## Example Deployment Architecture

The following describes one example deployment. Actual deployments may be
simpler or more complex depending on organisational requirements.

![Example deployment architecture](https://github.com/user-attachments/assets/20fb3567-ff84-47f3-9e42-367953881232)

1. The Agent connects to the OpAMP server at the network edge.
2. The OpAMP server constructs a `ServerToAgent` payload to send to the Agent.
3. Before sending, the OpAMP server submits the payload to an internal policy
   engine.
4. The policy engine evaluates whether the message is permitted for this Agent,
   applying whatever organizational constraints are relevant.
5. If the message is approved, the policy engine submits a signature request to
   a secure signer (typically a hardware security module).
6. The signer returns a signature over the payload bytes.
7. The OpAMP server wraps the payload and signature in a `SignedServerToAgent`
   envelope and delivers it to the Agent.

The key security property is structural isolation: the decision of *what is
allowed to be sent* is made by a component that is not directly reachable from
the network edge. An attacker who compromises the OpAMP server gains the ability
to send messages, but not the ability to have those messages accepted by Agents
with `RequiresPayloadTrustVerification` set — because the attacker cannot
produce valid signatures.

## Policy Engine Constraints

The policy engine can enforce any criteria the organization considers relevant.
Examples include:

- Denying specific message types outright (e.g. no `ServerToAgentCommand`).
- Enforcing per-customer opt-ins and opt-outs.
- Enforcing security invariants (e.g. a specific pipeline must never be
  disabled).
- Restricting which teams may push configuration changes.
- Requiring that only the latest approved version of a component may be
  installed.

These constraints could in principle be enforced client-side, but expressing
them flexibly would require significant complexity in Agent code. With Message
Attestation, the protocol defines a lightweight stamp ("this message was
authorized") and the Agent knows how to verify it; all bespoke policy logic
is maintained in the backend by the organization itself.

## Operational Considerations

### Trust Anchor Lifecycle

The payload trust anchor is a root CA certificate provisioned out-of-band on
each Agent. It is deliberately not rotatable via OpAMP messages, to prevent a
compromised server from redirecting Agents to an attacker-controlled anchor.

Operators should plan for trust anchor rotation using their existing
configuration-management tooling (e.g. Ansible, Chef, Puppet, or a secrets
manager). Using a long-lived root CA and shorter-lived signing intermediates
reduces rotation frequency for the trust anchor itself.

### Certificate Revocation

If a signing intermediate is compromised, standard X.509 revocation (CRL
distribution points or OCSP) handles it. The spec recommends enabling
revocation checking in the Agent's X.509 library. Operators may alternatively
use short-lived signing certificates as a substitute for active revocation.

If the root payload trust anchor itself is compromised, it must be replaced via
the same out-of-band mechanism used to provision it. This is an intentional
design constraint: no OpAMP message may update the trust anchor.
