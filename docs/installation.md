# Flatline Prototype Installation

## Running with Kubernetes

The recommended method of installing Flatline is with [Helm](https://helm.sh) on [Kubernetes](https://kubernetes.io).

However, this method is currently still intended to provide a testing environment, not a production one.

Although the Helm chart can be installed on any cluster, it defaults to targeting single-node [`k3s`](https://docs.k3s.io/quick-start) clusters.

### Install Kubernetes

If you do not have a Kubernetes cluster available, install a lightweight distribution such as [`k3s`](https://docs.k3s.io/quick-start).

After installing `k3s`, you may want to enable your non-root user to connect to the cluster:

```bash
mkdir -p $HOME/.kube
sudo cp /etc/rancher/k3s/k3s.yaml $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
chmod 600 $HOME/.kube/config

echo 'export KUBECONFIG=$HOME/.kube/config' >> $HOME/.profile
source $HOME/.profile
```

### Deploy the Helm Chart

From a client configured to the target Kubernetes cluster, clone the repository and install the chart.

This process will install Flatline for local testing, with bundled sample configurations and "secrets".

To deviate from these steps, review the [`values.yaml`](charts/flatline/values.yaml) file for defaults and [customization](#customizing-the-installation) options.

```bash
HELM_RELEASE=flatline # You can use a different name to identify your release.
git clone git@github.com:mollyim/flatline-platform.git && cd flatline-platform
helm install $HELM_RELEASE ./charts/flatline
```

When installation succeeds, follow the printed instructions to reach the deployed Flatline components.

### Customizing the Installation

The Flatline chart provides several options to customize the installation by overriding default values.

Some common customization options are:

- Overriding the bundled configuration files for the Flatline components.
- Disabling bundled local cloud service emulators to rely on the actual cloud service providers instead.
- Disabling bundled infrastructure components (e.g. Traefik, OpenTelemetry Collector...) to use existing ones.
- Using an existing StorageClass instead of the default [`k3s` local path provisioner](https://docs.k3s.io/storage).

These and other customizations are documented in the [`values.yaml`](charts/flatline/values.yaml) file.

You can read about [how to override values with Helm](https://helm.sh/docs/helm/helm_install/) in the official documentation.