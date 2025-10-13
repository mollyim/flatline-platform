# Flatline Prototype Compromises

The following document lists a series of know compromises that are made for the Flatline prototype. These compromises were made for the sake of keeping the scope of the prototype contained and to reduce the complexity of working in the development and testing of the prototype.

This list is not exhaustive and compromises may be added or removed as the development of the prototype evolves.

## Security

### Secrets

During the development of the Flatline prototype, all secrets (certificates, keys, passwords, seeds...) used to deploy a working version are committed to the repository. Although secrets are never hardcoded in the source code, they will be found in the development configuration files, the Whisper secrets bundle and in certain files used by the Helm chart, including its values file itself. This ensures that developers and testers can deploy an identical working version of the prototype during its development without having to generate or configure all of this secret material themselves.

### Registration

See the [Registration Service](architecture.md#registration-service) section in the architecture documentation.

### Encryption

### Authentication

### Key Transparency

See the [Key Transparency Server & Auditor](architecture.md#key-transparency-server--auditor) section in the architecture documentation.

### Key Recovery

See the [Secure Value Recovery](architecture.md#secure-value-recovery) section in the architecture documentation.

## Functionality

### Contact Discovery

See the [Contact Discovery Service](architecture.md#contact-discovery-service) section in the architecture documentation.

### Media Calls

Media calls are not yet implemented in the Flatline prototype. However, work is under way to do so during its development.
