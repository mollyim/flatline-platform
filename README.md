# 🚧 Work in Progress 🚧

Even in the `main` branch, resources from this repository are unstable in order to facilitate development.

During development, several features will be disabled or insecurely implemented.

Do not run this in production environments.

# Flatline Platform 

**Flatline** is a server prototype to which Signal-compatible clients can connect.

It relies on various [components](#components) forked from their original [Signal repositories](https://github.com/signalapp).

This repository holds the workflows, artifacts, infrastructure and documentation for these components.

## Components

Flatline is composed of multiple services organized under Flatline Platform as submodules.

- **Whisper Service**
  - Directory: [flatline-whisper-service](flatline-whisper-service/)
  - Repository: https://github.com/mollyim/flatline-whisper-service
  - Upstream: https://github.com/signalapp/Signal-Server
- **Storage Service**
  - Directory: [flatline-storage-service](flatline-storage-service/)
  - Repository: https://github.com/mollyim/flatline-storage-service
  - Upstream: https://github.com/signalapp/storage-service
- **Registration Service**
  - Directory: [flatline-registration-service](flatline-registration-service/)
  - Repository: https://github.com/mollyim/flatline-registration-service
  - Upstream: https://github.com/signalapp/registration-service
- **Contact Discovery Service**
  - Directory: [flatline-contact-discovery-service](flatline-contact-discovery-service/)
  - Repository: https://github.com/mollyim/flatline-contact-discovery-service
  - Upstream: https://github.com/signalapp/ContactDiscoveryService-Icelake

Additionally, Flatline relies on other infrastructure components which are found in this repository.
