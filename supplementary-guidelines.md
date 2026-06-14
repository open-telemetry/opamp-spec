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

```
  Agent             OpAMP Server       Policy Engine        Signer
                   (network edge)        (internal)          (HSM)
     │                   │                   │                 │
     │ (1) AgentToServer │                   │                 │
     ├──────────────────►│                   │                 │
     │                   │  (3) payload      │                 │
     │                   ├──────────────────►│                 │
     │                   │                   │ (5) sign req    │
     │                   │                   ├────────────────►│
     │                   │                   │ (6) signature   │
     │                   │                   │◄────────────────┤
     │                   │◄── signature ─────┤                 │
     │ (7) Signed        │                   │                 │
     │ ServerToAgent     │                   │                 │
     │◄──────────────────┤                   │                 │
```

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

## Certificate Hierarchy and Extended Key Usage

X.509 certificates carry an *Extended Key Usage* (EKU) field that declares
what a certificate is permitted to do. Two EKU values are relevant to Message
Attestation:

- **`id-kp-serverAuth`** — the certificate may authenticate a TLS server. TLS
  clients check for this when establishing a secure connection.
- **`id-kp-codeSigning`** — the certificate may sign arbitrary data. Message
  Attestation uses this EKU to mark signing certificates.

The spec requires the signing leaf certificate to carry `id-kp-codeSigning` and
prohibits `id-kp-serverAuth` on it. This means a TLS certificate cannot be
repurposed to sign OpAMP messages, and a signing certificate cannot be used as
a TLS server certificate.

### Do I need a separate root CA for signing?

No. The same root CA may issue both TLS and signing certificates, provided:

1. Each intermediate and leaf certificate carries only the appropriate EKU.
2. The signing private key is stored separately from the distribution server —
   for example, in an HSM or secrets manager the distribution server process
   cannot reach.

The security boundary is *key isolation*, not *CA isolation*. An attacker who
compromises the distribution server but cannot access the signing private key
cannot forge valid signed messages, regardless of whether TLS and signing
certificates share a root.

Operators who prefer strict CA separation may use separate roots, but it is not
required.

## Operational Considerations

### Trust Anchor Lifecycle

The payload trust anchor is a root CA certificate provisioned out-of-band on
each Agent. It is deliberately not rotatable via OpAMP messages, to prevent a
compromised server from redirecting Agents to an attacker-controlled anchor.

Operators should plan for trust anchor rotation using their existing
configuration-management tooling (e.g. Ansible, Chef, Puppet, or a secrets
manager). Using a long-lived root CA and shorter-lived signing intermediates
reduces rotation frequency for the trust anchor itself.

An alternative approach is to compile the trust anchor directly into the Agent
binary. In this model, trust anchor rotation is handled by distributing a new
Agent version — the same mechanism used for any other Agent update. This can be
simpler to operate in environments where Agent binary updates are already
automated, and it avoids the need for a separate certificate-management
pipeline.

### Certificate Revocation

If a signing intermediate is compromised, standard X.509 revocation (CRL
distribution points or OCSP) handles it. The spec recommends enabling
revocation checking in the Agent's X.509 library. Operators may alternatively
use short-lived signing certificates as a substitute for active revocation.

If the root payload trust anchor itself is compromised, it must be replaced via
the same out-of-band mechanism used to provision it. This is an intentional
design constraint: no OpAMP message may update the trust anchor.
