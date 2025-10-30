# Flatline Prototype Compromises

The following document lists a series of know compromises made for the Flatline prototype. These compromises were made for the sake of keeping the scope of the prototype contained and to reduce the complexity of working in the development and testing of the prototype. This list aims to identify them so that they can be addressed after the protoype stage is completed.

This list is not exhaustive and compromises may be added or removed as development of the prototype evolves.

## Security

### Secrets

During the development of the Flatline prototype, all secrets (certificates, keys, passwords, seeds...) used to deploy a working version are committed to the repository. Although secrets are never hardcoded in the source code, they will be found in the development configuration files, the Whisper secrets bundle and in certain files used by the Helm chart, including its values file. This ensures that developers and testers can deploy an identical working version of the prototype during its development without having to generate or configure all of this secret material themselves.

Although they are secrets in the context in which they are used in Flatline, "secrets" are not treated as such during the development of the prototype. In the future, secrets should be securely provisioned and managed using the appropriate Kubernetes resources.

### Authentication

Some Flatline components are deployed without authentication in the prototype. An example is Localstack, which allows any unauthenticated client full access to any of the [simulated AWS infrastructure](architecture.md#localstack). In the future, every Flatline component should implement robust authentication.

### Encryption in Transit

Although most external communication with Flatline components is encrypted in transit by Traefik in addition to the native end-to-end encryption, internal communication between Flatline components is not. In the future, service-to-service communication should be encrypted in transit when supported by the component.

### Networking

Networking for the prototype is very rudimentary. Kubernetes pods that require handling non-HTTP traffic use the host network and there are no network policies that prevent communication between components that are not required to communicate with each other. In the future, all ingress traffic should be handled by an ingress gateway and network policies should only allow internal traffic that is strictly necessary for Flatline to operate.

### Hardening

The Kubernetes resources installed by the Helm chart have not been hardened. I addition to the [lack of network security](#networking), pod security standards are not enforced nor observed, container capabilities are not restricted and security features such as user namespaces and security context options are not configured. In the future, Kubernetes resources should be hardened to reduce the likelyhood and impact of a security incident.

### Registration

See the [Registration Service](architecture.md#registration-service) section in the architecture documentation.

### Key Recovery

See the [Secure Value Recovery](architecture.md#secure-value-recovery) section in the architecture documentation.

### Key Transparency

See the [Key Transparency Server & Auditor](architecture.md#key-transparency-server--auditor) section in the architecture documentation.

## Development and Operations

### Testing

When some functionality has been disabled or changed, tests for that functionality have ocassionally been disabled, rather than updating to reflect the new expected behavior for Flatline. In the future, existing tests should be rewritten and new tests created for any changed or new functionality.

Additionally, Flatline does not yet implement end-to-end testing.

### Migrations

Data migrations are not yet implemented. For this reason, some future upgrades to the Helm installation may require manual intervention or even a complete re-install when they involve database schema changes. In the future, Helm hooks should be used to enforce the successful migration of persistent data to conform with any required schema changes.

### Observability

Although many of the Flatline components provide means of reporting metrics and logs, this data is not generally collected nor stored in a way that allows any meaningful observability. The Helm chart does not provide means of configuring this and only provides a [metrics collector](architecture.md#opentelemetry-collector) for instances where such a component is functionally required. In the future, all components that support it should be able to report logs and metrics to a compatible repository configured through the Helm chart.

### Literal Duplication

Some literals, [especially "secrets"](#secrets), that are shared between components are still duplicated in their respective configuration files. This means that changing such values will require searching for other instances where the value is used. These values are usually (but not always) found together with comments explaining this. In the future, shared values should be defined in the Helm chart and injected in any components that require them.