# Flatline Prototype Registration

This document explains the changes to the account registration process that were made in the Flatline prototype.

## Context

Originally, accounts were associated to a phone number. To register an account with a certain phone number, a client would have to verify ownership over that phone number. This was done by an independent component, the [registration service](https://github.com/signalapp/registration-service). This component would send a code via SMS or phone call to the registering phone number, which would be used by the client as a challenge to prove ownership over that phone number.

This original process would have the following tradeoffs:

- Users would need to own a phone number to register an account. 
- Users owning only one phone number would only be able to register one account.
- The phone network was trusted with the integrity of the verification process.
- Commercial services were required to communicate over the phone network.

## Verification

In Flatline, accounts are no longer associated to a phone number specifically. Instead, they are associated with a principal. Principals are represented an arbitrary printable ASCII strings, which can themselves represent any thing: a random identifier, username, email address, public key or even a phone number.

To register an account with a specific principal, clients can use any of the trusted verification providers configured in the Flatline instance they want to register in. These verification providers are OpenID Connect providers that both client and server will communicate with.

The client will need to authenticate with an identity in one of the providers offered by the Flatline instance in order to prove ownership over a principal. When setting up Flatline, the operator will decide which claim from the identity token returned by the verification provider should be used as the principal. By default, the subject claim (i.e. "sub") is used as the principal.

For any given Flatline instance, there can only be one account with the same principal. Even if multiple verification providers are offered to clients, only one can be used to register the same identity. Likewise, even if the resulting principal would be different, the same verification provider and subject (the "sub" claim from the identity token) can only be used to register a single account.

This new process has the following benefits:

- Users do not need to own a phone number to register an account.
- Users can register as many accounts as identities they own in the trusted identity providers.
- The Flatline operator has freedom in which identity providers to trust with the verification process.
- The Flatline operator can self-host their own OpenID Connect identity provider to act as a verification provider.

## Workflow

In the Flatline prototype, the registration/verification process generally works as follows:

1. Client requests a list of verification providers with `GET /v1/verification`.
2. Client starts verification with the chosen verification provider with `POST /v1/verification`.
  - a. In its request, client provides `providerId`, `codeChallenge`, `state`, and `redirectUri`.
  - b. Whisper creates random `sessionId` and `nonce` and requests PAR with the chosen provider.
  - c. Whisper creates and persists an unverified verification session.
  - d. Whisper returns the `sessionId`, provider `authorizationEndpoint` and `clientId` as well as PAR details.
3. Client visits the returned PAR `requestUri` before its expiration and authenticates. Gets `code` and `codeVerifier`.
4. Client completes verification of the session with `PATCH /v1/verification/<sessionId>`.
  - a. In its request, client provides `sessionId`, `code` and `codeVerifier`. Other session details are already stored.
  - b. Whisper requests a token from the provider with the `clientId`, `code`, `codeVerifier` and `redirectUri`.
  - c. Whisper verifies that the token and its signature are valid for the configured verification provider.
  - d. Whisper retrieves the token claim that maps to the principal for that provider, defaulting to the subject claim.
  - e. Whisper marks the verification session as verified for that principal and the subject claim found in the token.
  - f. Whisper returns the principal that has been verified for the session.
5. Client registers account with `POST /v1/registration`:
  - a. In its request, client provides `sessionId` and other account details, including the requested principal.
  - b. Whisper verifies that the verification session is verified and that its principal matches the one requested.
  - c. Whisper performs the pre-existing recovery and re-registration checks.
  - d. In the prototype, re-registration is denied if the verification provider has changed.
  - e. The account is created with the verified principal and associated to the verification provider and subject.

This workflow is built on top of the following specifications:

- [RFC 6749: The OAuth 2.0 Authorization Framework](https://www.rfc-editor.org/rfc/rfc6749)
- [RFC 7636: Proof Key for Code Exchange by OAuth Public Clients](https://datatracker.ietf.org/doc/html/rfc7636)
- [RFC 9126: OAuth 2.0 Pushed Authorization Requests](https://datatracker.ietf.org/doc/html/rfc9126)

## Relevant Implementation Details

- The [Nimbus](https://connect2id.com/products/nimbus-oauth-openid-connect-sdk) library is used for working with OAuth 2.0, PAR, JWT, JWK, JWKS...
- The identity token that is used for verification is obtained from the verification provider through a [PKCE](https://datatracker.ietf.org/doc/html/rfc7636) flow with [PAR](https://datatracker.ietf.org/doc/html/rfc9126).
- Public keys (i.e. the response from the JWKS URI) for each verification provider are trusted on first use and stored.
- The cache of trusted keys can be cleared (completely or by URI) via CLI with the new `clear-verification-keys` command.
- The verification (`/v1/verification`) and registration (`/v1/registration`) controller APIs have experienced breaking changes.
- Rate limiting is implemented when starting a verification session to prevent DoS to the verification provider.
