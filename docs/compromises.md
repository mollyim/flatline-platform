# Flatline Prototype Compromises

The following document lists a series of know compromises that are made for the Flatline prototype. These compromises were made for the sake of keeping the scope of the prototype contained and to reduce the complexity of working in the development and testing of the prototype.

This list is not exhaustive and compromises may be added or removed as the development of the prototype evolves.

## Security

### Secrets

During the development of the Flatline prototype, all secrets (certificates, keys, passwords, seeds...) used to deploy a working version are committed to the repository. Although secrets are never hardcoded in the source code, they will be found in the development configuration files, the Whisper secrets bundle and in certain files used by the Helm chart, including its values file. This ensures that developers and testers can deploy an identical working version of the prototype during its development without having to generate or configure all of this secret material themselves.

Although they are "secrets" in the context in which they are used, they are not treated as such during the development of the prototype.

### Registration

See the [Registration Service](architecture.md#registration-service) section in the architecture documentation.

### Networking 

Networking for the prototype is still very rudimentary. Kubernetes pods that require handling non-HTTP traffic use the host network and there are no network policies that prevent communication between components that are not required to communicate with each other. In the future, all outside traffic should be handled by an ingress gateway and network policies should only allow the traffic that is strictly necessary for Flatline to operate. 

### Encryption in Transit

Not all components communicate via 

### Authentication

- Localstack

### Key Transparency

See the [Key Transparency Server & Auditor](architecture.md#key-transparency-server--auditor) section in the architecture documentation.

### Key Recovery

See the [Secure Value Recovery](architecture.md#secure-value-recovery) section in the architecture documentation.

## Functionality

### Contact Discovery

See the [Contact Discovery Service](architecture.md#contact-discovery-service) section in the architecture documentation.

## Operation 

### Literal Duplication

Some literals, [especially "secrets"](#secrets), that are shared between components are still duplicated in their respective configuration files. This means that changing such values will require searching for other instances where the value is used. Such values often have commends explaining this. In the future, these values should ideally be defined via the Helm chart values and injected in any components that require them.

### Observability

Although many of the Flatline components provide means of reporting metrics and logs, this data is not generally collected nor stored in a way that allows any meaningful observability. The Helm chart does not provide means of configuring this and only provides a [metrics collector](architecture.md#opentelemetry-collector) for instances where such a component is functionally required. In the future, all components that support it should be able to report logs and metrics to a compatible repository configured through the Helm chart.