# 🚧 Work in Progress 🚧

Even in the `main` branch, resources from this repository are unstable in order to facilitate development.

During development, several features will be disabled or insecurely implemented.

Do not run this in production environments.

# Flatline Platform 

**Flatline** is a server prototype to which Signal-compatible clients can connect.

It relies on various [components](#components) forked from their original [Signal repositories](https://github.com/signalapp).

This repository holds the [artifacts](https://github.com/orgs/mollyim/packages?repo_name=flatline-platform), [workflows](.github/workflows), [infrastructure](charts/flatline) and documentation for these components.

## Documentation

- [**Architecture**](docs/architecture.md): To learn about the components of the Flatline prototype.
- [**Compromises**](docs/compromises.md): To learn about the compromises made for the Flatline prototype.
- [**Installation**](docs/installation.md): To learn how to install the Flatline prototype in Kubernetes.
- [**Evaluation**](docs/evaluation.md): To learn how to evaluate the Flatline prototype with Molly.
- [**Development**](docs/development.md): To learn how to develop and customize the Flatline prototype.

## Features

The following is a non-comprehensive list of client features currently supported by the Flatline prototype.

Some of those features may be subject to the [compromises](docs/compromises.md) made for the prototype.

- Account Creation
- Direct/Group Messaging
- Direct/Group Multimedia Calls
- Attachment Sending/Receiving
- Notifications (WebSocket) 
- Group Management
- Profile Customization
- Voice Notes
- Stories
- Location Sharing

### Non-Features

The following notable features are currently missing from the prototype.

For more details, see the [compromises](docs/compromises.md) documentation.

- Phone Verification
- Contact Discovery
- Key Recovery
- Backups
- Payments
- Donations
- Spam Protection 

## Components

Flatline is composed of multiple services organized under Flatline Platform as submodules.

- **Whisper Service**
  - Submodule: `flatline-whisper-service`
  - Repository: https://github.com/mollyim/flatline-whisper-service
  - Upstream: https://github.com/signalapp/Signal-Server
- **Storage Service**
  - Submodule: `flatline-storage-service`
  - Repository: https://github.com/mollyim/flatline-storage-service
  - Upstream: https://github.com/signalapp/storage-service
- **Registration Service**
  - Submodule: `flatline-registration-service`
  - Repository: https://github.com/mollyim/flatline-registration-service
  - Upstream: https://github.com/signalapp/registration-service
- **Contact Discovery Service**
  - Submodule: `flatline-contact-discovery-service`
  - Repository: https://github.com/mollyim/flatline-contact-discovery-service
  - Upstream: https://github.com/signalapp/ContactDiscoveryService-Icelake
- **Calling Service**
  - Submodule: `flatline-calling-service`
  - Repository: https://github.com/mollyim/flatline-calling-service
  - Upstream: https://github.com/signalapp/Signal-Calling-Service

For a more detailed description of all Flatline components, see the [architecture documentation](docs/architecture.md).
