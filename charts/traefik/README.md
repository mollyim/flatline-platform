### Kubernetes cluster without Traefik

If your Kubernetes cluster does not ship a Traefik pod by default, you can use this Traefik chart:

- Add Traefik's chart repository:

```console
helm repo add traefik https://traefik.github.io/charts
helm repo update
```

- Install the Traefik chart:

```console
helm install traefik ./charts/traefik
```

- You may need to remove `traefikResources.valuesOverride` from the flatline values.

Resources:
- <https://github.com/traefik/traefik-helm-chart>
