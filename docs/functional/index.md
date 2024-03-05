---
layout: page
title: High Level Functional Description
hero_height: is-fullwidth
---

# High Level functional description

# Introduction

Please note that the high-level component diagram provided below is only functional in nature and is meant to inform the
reader mainly about the the credential APIs available for the 3 different roles (Issuer, Holder/Wallet and Relying
Party). The diagram explains the components which are explained in more details in the rest of this document

The diagram is generic in nature and not tied to any implementation

![](../static/High-level-roles-APIs.png)
[Plant UML source](../assets/High-level-roles-APIs.puml)

> Legend:
>
> - KMS: Key Management System. This component is responsible for importing, generating and optionally exporting
    cryptographic keys, which are typically asymmetrical using a private and public Key. The KMS also can generate
    signatures
    and perform encryption using these key, reason for this typical coupling is that some keys are protected by hardware
    and often cannot be exported. The KMS should support Json Web Keys (JWKs).
> - DID: Decentralized Identifier Management. This optional component provides DID resolution as well as management (
    create, update, delete) of services, keys and the full DID. DIDs are used to bind 0 or more public keys to a
    persistent identifier amongst others.
> - Auth:

## ARF

We take the ARF as a starting point, meaning Identity Wallet use cases for (Q)EAA must be supported. This does not
mean that other frameworks or technical interactions would not be supported.

- **PID Provider:** The authoritative source issuing Personal (or Legal) Identification Data (PID) according to EiDAS2.
  Consisting of:
    - **OID4VCI Component:** based on the "OpenID for Verifiable Credential Issuance"
      specification [OIDC4VCI. Draft 13](https://openid.bitbucket.io/connect/openid-4-verifiable-credential-issuance-1_0.html)
      to issue the PID.
    - **National/eIDAS Identity Provider:** A preexisting identity systems based on SAML2 or OpenID Connect Core 1.0, as
      used in the different Member States. Examples: DigiD (NL), e-Herkenning (NL)
    - **Relying Party:** A component, authenticating the User with the national/eIDAS Identity Provider above
- **(Q)EAA Provider:** A authoritative (requires QEAA) or non-authoritative (either QEAA or EAA) source issuing
  Personal (or Legal) attributes
    - **OID4VCI Component:** based on the "OpenID for Verifiable Credential Issuance"
      specification [OIDC4VCI. Draft 13](https://openid.bitbucket.io/connect/openid-4-verifiable-credential-issuance-1_0.html)
      to issue the (Q)EAA.
    - **Relying Party:** A component, authenticating the User. Depending on the use case authentication can be done with
        - **the PID (_likely for QEAA only_):** in which case the (Q)EAA will act as a Relying Party (Verifier) for a
          Presentation created by the Wallet Instance, according to
          the [OID4VP, Draft 20](https://openid.net/specs/openid-4-verifiable-presentations-1_0.html) specification.
        -

## Generic components needed in OID4VC/ARF

[//]: # (![]&#40;../assets/OID4VCI.svg&#41;)

# (Q)EAA Issuance

## High level PID flow

> TODO

## High level (Q)EAA issuance flow

The figure below shows a general architecture and highlights the main steps when issuing a (Q)EAA. Please note that some
trust frameworks might need additional steps.

The following assumptions have been made:

- the User optionally provides the RP with a valid PID, stored in their wallet
- The User provides the RP with zero or more (Q)EAAs, stored in their wallet as optional pre-requisite
- The Issuer and Wallet operate in a trust framework, which is either based on:
    - OpenID Connect Federation
    - EBSI
- A high security implementation profile is required (HAIP)

![](../assets/High%20Level%20QEAA%20issuance%20flow.drawio.svg)

The steps involved:

1. **Credential Offer:** The issuer optionally creates a Credential Offer. The Credential Offer is mandatory for the
   pre-authorized code flow and optional for the authorized code flow, because the authorized code flow could make a
   similar redirect after authentication.

2. **Discovery of the (Q)EAA Provider:** the Wallet Instance obtains the list of the trusted (Q)EAA Provider using the
   Federation API (e.g.: using the Subordinate Listing Endpoint of the Trust Anchor and its Intermediates), then
   inspects
   the metadata and Trust Mark looking for the Digital Credential capabilities of each (Q)EAA Provider.


3. **(Q)EAA Provider OID4VCI Issuer Metadata:** the Wallet Instance
   obtains the Metadata that discloses the formats of the (Q)EAA, the algorithms supported, and any other parameter
   required.

4. User Authentication: the (Q)EAA Provider, acting as a Relying Party, authenticates the User evaluating the
   presentation of the PID, (Q)EAA. For this part either SIOPv2 or OIDC is being used to authenticate the user.
   Depending on whether a PID and/or (Q)EAA is request from the (Q)EAA Provider a Verifiable Presentation is created. A
   proof of JWK or DID as key material is required here as well.
   This is using the Authorization Code or Pre-Authorized code Flow, defined
   in [OIDC4VCI. Draft 13](https://openid.bitbucket.io/connect/openid-4-verifiable-credential-issuance-1_0.html). The (
   Q)EAA Provider optionally looks up the Wallet Instance attestation using the trust
   framework

5. (Q)EAA Issuance: the Wallet is authenticated with a valid PID and the (Q)EAA Provider issuer a (Q)EAA bound to the
   key material held by the requesting Wallet Instance. The Wallet Instance request one or more (Q)EAAs from the (Q)EAA
   Provider and subsequently receives them either synchronously or asynchronously.

# (Q)EAA Verification

# High level (Q)EAA verification flow

![](../static/High%20Level%20QEAA%20verification%20flow.drawio.svg)

1. **Client Registration (optional):** The relying party (RP) or client must register with the OpenID provider (OP).
   This involves obtaining an optional client ID and client secret to authenticate and interact with the OP. If not used
   metadata can be passed as part of the Authorization Request.
2. **Discovery of the (Q)EAA RP (optional):** the Wallet Instance obtains the list of the trusted (Q)EAA RPs using the
   Federation API

3. **Authorization Request:** The RP initiates the authentication process by redirecting the user to the OP. The request
   includes parameters such as client ID, scope, and redirect URI.
    - **Claims Request:** The RP may request specific claims or information about the user to be included in the
      verifiable
      presentation.

4. **User Consent:** The user is prompted to authenticate themselves and grant consent to share specific information
   with the
   RP.

5. **Authorization Response:** Upon successful authentication and consent, the OP issues an ID token containing the
   user's identity
   information. Additionally, the OP generates a verifiable presentation containing the requested claims.
   Response to RP: The OP sends the ID token and verifiable presentation to the RP's specified redirect URI.
   Presentation Verification by RP:

6. **RP Validates Tokens and (Q)EAA** The RP validates the ID token (SIOPv2/OIDC) if present, ensuring its integrity and
   authenticity.
   Presentation Validation: The RP verifies the Verifiable presentation, checking the cryptographic signatures and
   ensuring
   that the claims match the requested ones.

7. **Resource Access:** Upon successful verification of the ID token and verifiable presentation, the RP can use the
   information to grant access to resources or services for the authenticated user.

# Authentication

## OpenID Connect/SAML

## SIOPv2

# Trust
