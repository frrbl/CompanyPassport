## Issuance using Authorization Code flow

![]({{'assets/Issuance-Authorization-code.svg' | relative_url }})

See source [Diagram]({{'/assets/Issuance-Authorization-code.puml' | relative_url}}) or [Image]({{'/assets/Issuance-Authorization-code.svg' | relative_url}})

### Initialization:
1. **(Wallet initiated)** The user opens and unlocks the wallet .
2. **(Wallet initiated)** The user opens the wallet provided credential catalogue of pre-configured (Q)EAA Providers. After a (Q)EAA is selected the Wallet continues the flow with the preconfigured Credential Issuer URL and credential identifier. No Resource server/web page is involved

**Or**
3. **(Issuer initiated)** User browses to (Q)EAA Provider's website.
4. **(Issuer initiated)** Browser opens the Resource server/website, either provided by the (Q)EAA Provider's or an external entity
5. **(Issuer initiated)** Resource server request to create a credential offer with the (Q)eAA Provider. Optionally providing a state value and information to be stored in the credential (can also be done later)

For the unique issuer_state, the (Q)EAA Provider either:

a) Offline signed JWT
6. **(Issuer initiated)** Creates an offline signed JWT itself using a private key, trusted by the IDP. The benefit is that the IDP needs little integration. The provider is responsible for storing this in a session somehow

b) IDP session/token

7. b) **(Issuer initiated)** Or sends a request to the IDP, asking it to create a session and unique issuer_state. The IDP is now responsible for the session and state. State is either a JWT or opaque token
8. b) **(Issuer initiated)** The IDP sends back the session and issuer_state to the (Q)EAA provider in the previous case

b) IDP session/token

9. c) **(Issuer initiated)** Delegate credential offer creation to the IDP\n Step 004, could of course also happen directly against the IDP in this case
10. c) **(Issuer initiated)** The IDP returns the credential offer.


d) **(Issuer initiated)** The credential offer was completely static, which could be used with a Authorization code flow only; This is currently not supported by our issuer component yet;


11. **(Issuer initiated)** Credential offer(s) for QR and/or deeplink are returned to the Resource server, optionally including a QR code as image next to the value(s)
12. **(Issuer initiated)** returns a HTML page to the browser containing a Credential Offer; containing
    - the Credential Issuer URL
    - an identifier to the offered credential
    - an optional issuer_state parameter to bind this issuance to a pre-existing session with the Provider
13. **(Issuer initiated)** The user unlocks the wallet

### Status feedback

14. The Resource server could ask for regular status updates from the (Q)EAA Provider. This allows the website to inform the user via the browser about progress and/or errors. There are 2 possibilities (only the first one is currently supported). A regular POST to a status endpoint or a regular callback to a URL. 
15. The Resource Server does a regular POST or GET to the status endpoint of the (Q)EAA; Or the browser does this directly with the Provider using a secure host-only cookie
16. The Provider matches the requested ID with it's internal session, optionally using the IDP.
17. and 18. The (Q)EAA Provider returns a status/error response and the Resource Server updates its webpage

### Metadata
19. The Wallet fetches the Credential Issuer's metadata from the ./well-known files of the Credential Issuer URL
20. The (Q)EAA Provider returns the Credential Issuer Metadata; containing:
    - information about the Issuer supported credentials, key types, DID methods
    - translations and display information like order of attestations, logo's and colors for the offered credentials 
21. The Wallet shows information about the (Q)EAA Provider and the offered (Q)EAA to the user and asks for consent
22. The user consents and optionally selects multiple (Q)EAAs if supported (**(Issuer initiated)**)

### Wallet attestations (WIP, not supported yet)
- The Wallet retrieves a nonce for the client attestation from the (Q)EAA Provider; //could also be the state if provided// 
- The (Q)EAA Provider generates a nonce and links it to a session managed by the (Q)EAA Provider
- Or the (Q)EAA Provider delegate to the IDP to generate the nonce and bind it to its session
- In the latter case the IDP would return the nonce to the (Q)EAA Provider.
- The (Q)EAA Provider returns the nonce to the Wallet 
- The Wallet fetches fresh client attestation from the Wallet Provider backend 
- The Wallet generates proof of possession (PoP) using the nonce fetched in the previous step and the private key for wallet attestations

### Authentication
23. The Wallet sends a Pushed Authorization Request (PAR) to the (Q)EAA Provider; containing:
    - the Wallet Provider's client_id
    - a PKCE code_challenge
    - The issuer_state value
    - the client attestation and proof of possession
    - a redirect_uri containing an app deeplink
    - an identifier for the requested (Q)EAA 
24. The (Q)EAA Provider either verifies the Offline state JWT signed by the issuer using its known public key
25. Or the (Q)EAA Provider verifies the session info and issuer_state
26. The (Q)EAA Provider verifies the wallet/client attestation and validates the status of the Wallet instance through a trust list
27. The IDP returns the PAR response including the request_uri and expires_in values to the Wallet 
28. The Wallet uses the request_uri to create an Authorization Request and is opening the Wallets default browser using the URL. 
29. The Browser sends the Authorization Request to the IDP 
30. The IDP may exchange any information via the browser to the user, using the front channel. This can for instance be:
    - username / password auth
    - OID4VP requesting other (Q)EAA, etc..
    - E-herkenning, IDIN, DigiD  
    - 2FA/MFA 
31. The IDP responds with an Authorization Response; containing
    - the auth code
    - the redirect provided by the wallet in the PAR
32. The browser follows the redirect, launching the wallet 
33. The Wallet sends a Token Request to the IDP; containing:
    - the auth code from Authorization Response
    - the PKCE code_verifier matching the code_challenge from Authorization Request
    - the client attestation and Proof of possession
    - a DPoP key, which will be used later during the Credential Request 
34. The Issuer does a lookup for the code, verifies the PKCE code_verifier against the already known code_challenge. It then generates an access token bound to the DPoP public key.
35. It verifies the client attestation. (note this could be part of step 40. Obviously the response will only be created once everything is in order)
36. The IDP sends a Token Response; containing
    - DPoP-bound access token
    - a unique c_nonce, which later will be used to sign the Credential request 
37. The Wallet optionally generates a key pair for the device binding of the (Q)EAA and signs the c_nonce. The key pair could be unique per request, or per issuer
38. The Wallet sends the Credential Request to the Issuer; containing
    - the DPoP-bound access token
    - the proof of device binding key signed c_nonce
    
**TODO: Deferred and batch credential here**
    
39. The Issuer validates the access_token and the proof in case it is an offline JWT from the IDP
40. Or the issuer uses the IDPs userinfo or introspect endpoints using the access token to verify the access token in cass the token is used online or is opaque
41. In this case the IDP returns a successful response, it is verified, in case of error it is not
42. The (Q)EAA Provider validates the subject key proof with the signature and c_nonce value

### Issuance of the (Q)EAA or W3C JWT VC
The next few steps highlight the different credential formats. The actual attestation data can either be fetched by the Issuer at this point using a callback/hook from the issuer perspective. This could be a Database lookup, REST call, or for instance the information provided during creation of the credential offer (Provider initiated only)

43. 9**(JSON-LD (Q)EAA)** The (Q)EAA Provider creates a W3C JSON-LD Verifiable Credential with its *private key* containing
    - attestation data
    - *public key or DID* as issuer (id)
44. **(SD-JWT (Q)EAA)** The (Q)EAA Provider creates the Disclosures from attestation data and signs the SD-JWT with *private key* containing
    - attestation data and hashed Disclosures as the user claims
    - *public key or DID* as cnf claim 
    - appends the full Disclosure(s).
45. **(mdoc (Q)EAA)** The (Q)EAA Provider creates the hashed Releases from attestation data and signs the MDOC with *private key* containing
    - attestation data and hashed Releases as issuerAuth
    - *public key* as deviceKeyInfo
46. **(JWT VC)** The (Q)EAA Provider creates a W3C JWT encoded Verifiable Credential with its *private key* containing
    - attestation data
    - *public key or DID* as iss claim 
47. The (Q)EAA Provider sends the Credential Response; containing:
    - The (Q)EAA as credential
48. Optional user consent to accept the (Q)EAA and store it
49. The Wallet stores the (Q)EAA and the associated keys.
50. **(Issuer initiated)** Optional success feedback to user browser
