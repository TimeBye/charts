# Helm Chart for hackmd

## Introduction

This [hackmd](https://hackmd.io/) chart installs [hackmdio/codimd](https://github.com/hackmdio/codimd) in a Kubernetes cluster.

## Prerequisites

- Kubernetes cluster 1.10+
- Helm 2.8.0+

## Installation

### Add chart repository

Add chart repository and cache index.

```bash
helm repo add timebye https://timebye.github.io/charts/
helm repo update
```

### Configure the chart

The following items can be configured in `values.yaml` or set via `--set` flag during installation.

#### Configure the way how to expose hackmd service:

- **Ingress**: The ingress controller must be installed in the Kubernetes cluster.  
- **ClusterIP**: Exposes the service on a cluster-internal IP. Choosing this value makes the service only reachable from within the cluster.
- **NodePort**: Exposes the service on each Node’s IP at a static port (the NodePort). You’ll be able to contact the NodePort service, from outside the cluster, by requesting `NodeIP:NodePort`. 
- **LoadBalancer**: Exposes the service externally using a cloud provider’s load balancer.  

#### Configure the way how to persistent data:

- **Disable**: The data does not survive the termination of a pod.
- **Persistent Volume Claim(default)**: A default `StorageClass` is needed in the Kubernetes cluster to dynamic provision the volumes. Specify another StorageClass in the `storageClass` or set `existingClaim` if you have already existing persistent volumes to use.

#### Configure the other items listed in [configuration](#configuration) section.

### Install the chart

Install the hackmd helm chart with a release name `my-hackmd`:

```bash
# helm v2
helm install timebye/hackmd \
  --name my-hackmd \
  --set expose.ingress.host=hackmd.cluster.local

# helm v3
helm install my-hackmd timebye/hackmd \
  --set expose.ingress.host=hackmd.cluster.local
```

## Uninstallation

To uninstall/delete the `my-hackmd` deployment:

```bash
# helm v2
helm delete --purge my-hackmd

# helm v3
helm uninstall my-hackmd
```

## Configuration

The following table lists the configurable parameters of the hackmd chart and the default values.

| Parameter                                                  | Description                                                                                                                                                                                                                                                                   | Default                                   |
| ---------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------- |
| **Expose**                                                 |                                                                                                                                                                                                                                                                               |                                           |
| `expose.type`                                              | The way how to expose the service: `ingress`、`clusterIP`、`loadBalancer` or `nodePort`                                                                                                                                                                                       | `ingress`                                 |
| `expose.tls.enabled`                                       | Enable the tls or not                                                                                                                                                                                                                                                         | `false`                                   |
| `expose.tls.secretName`                                    | Fill the name of secret if you want to use your own TLS certificate. The secret must contain keys named:`tls.crt` - the certificate, `tls.key` - the private key, `ca.crt` - the certificate of CA.These files will be generated automatically if the `secretName` is not set |                                           |
| `expose.tls.certExpiry`                                    | Automatically generated self-signed certificate validity period(day)                                                                                                                                                                                                          | `3650`                                    |
| `expose.ingress.host`                                      | The host of hackmd service in ingress rule                                                                                                                                                                                                                                  | `hackmd.cluster.local`                  |
| `expose.ingress.annotations`                               | The annotations used in ingress                                                                                                                                                                                                                                               |                                           |
| `expose.clusterIP.name`                                    | The name of ClusterIP service                                                                                                                                                                                                                                                 | `Release.Name`                            |
| `expose.clusterIP.port`                                    | The service port hackmd listens on when serving with HTTP                                                                                                                                                                                                                   | `80`                                      |
| `expose.nodePort.name`                                     | The name of NodePort service                                                                                                                                                                                                                                                  | `Release.Name`                            |
| `expose.nodePort.port`                                     | The service port hackmd listens on when serving with HTTP                                                                                                                                                                                                                   | `80`                                      |
| `expose.nodePort.nodePort`                                 | The node port hackmd listens on when serving with HTTP                                                                                                                                                                                                                      |                                           |
| `expose.loadBalancer.name`                                 | The name of LoadBalancer service                                                                                                                                                                                                                                              | `Release.Name`                            |
| `expose.loadBalancer.port`                                 | The service port hackmd listens on when serving with HTTP                                                                                                                                                                                                                  | `80`                                      |
| **Persistence**                                            |                                                                                                                                                                                                                                                                               |                                           |
| `persistence.enabled`                                      | Enable the data persistence or not                                                                                                                                                                                                                                            | `false`                                   |
| `persistence.resourcePolicy`                               | Setting it to `keep` to avoid removing PVCs during a helm delete operation. Leaving it empty will delete PVCs after the chart deleted                                                                                                                                         | `keep`                                    |
| `persistence.persistentVolumeClaim.core.existingClaim`     | Use the existing PVC which must be created manually before bound, and specify the `subPath` if the PVC is shared with other components                                                                                                                                        |                                           |
| `persistence.persistentVolumeClaim.core.storageClass`      | Specify the `storageClass` used to provision the volume. Or the default StorageClass will be used(the default). Set it to `-` to disable dynamic provisioning                                                                                                                 |                                           |
| `persistence.persistentVolumeClaim.core.subPath`           | The sub path used in the volume                                                                                                                                                                                                                                               |                                           |
| `persistence.persistentVolumeClaim.core.accessMode`        | The access mode of the volume                                                                                                                                                                                                                                                 | `ReadWriteMany`                           |
| `persistence.persistentVolumeClaim.core.size`              | The size of the volume                                                                                                                                                                                                                                                        | `5Gi`                                     |
| `persistence.persistentVolumeClaim.database.existingClaim` | Use the existing PVC which must be created manually before bound, and specify the `subPath` if the PVC is shared with other components. If external database is used, the setting will be ignored                                                                             |                                           |
| `persistence.persistentVolumeClaim.database.storageClass`  | Specify the `storageClass` used to provision the volume. Or the default StorageClass will be used(the default). Set it to `-` to disable dynamic provisioning. If external database is used, the setting will be ignored                                                      |                                           |
| `persistence.persistentVolumeClaim.database.subPath`       | The sub path used in the volume. If external database is used, the setting will be ignored                                                                                                                                                                                    |                                           |
| `persistence.persistentVolumeClaim.database.accessMode`    | The access mode of the volume. If external database is used, the setting will be ignored                                                                                                                                                                                      | `ReadWriteOnce`                           |
| `persistence.persistentVolumeClaim.database.size`          | The size of the volume. If external database is used, the setting will be ignored                                                                                                                                                                                             | `1Gi`                                     |
| **General**                                                |                                                                                                                                                                                                                                                                               |                                           |
| `imagePullPolicy`                                          | The image pull policy                                                                                                                                                                                                                                                         | `IfNotPresent`                            |
| **Core**                                                   |                                                                                                                                                                                                                                                                               |                                           |
| `core.image.repository`                                    | Repository for hackmd image                                                                                                                                                                                                                                                   | `quay.azk8s.cn/setzero/docker-hackmd`     |
| `core.image.tag`                                           | Tag for hackmd core image                                                                                                                                                                                                                                                     | `v12.3.5`                                 |
| `core.replicas`                                            | The replica count                                                                                                                                                                                                                                                             | `1`                                       |
| `core.healthCheckToken`                                    | An access token needs to be provided while accessing the probe endpoints.                                                                                                                                                                                                     | `SXBAQichEJasbtDSygrD`                    |
| `core.resources`                                           | The [resources] to allocate for container                                                                                                                                                                                                                                     | undefined                                 |
| `core.nodeSelector`                                        | Node labels for pod assignment                                                                                                                                                                                                                                                | `{}`                                      |
| `core.tolerations`                                         | Tolerations for pod assignment                                                                                                                                                                                                                                                | `[]`                                      |
| `core.affinity`                                            | Node/Pod affinities                                                                                                                                                                                                                                                           | `{}`                                      |
| `core.podAnnotations`                                      | Annotations to add to the core pod                                                                                                                                                                                                                                            | `{}`                                      |
| `core.env`                                                 | The [available options] that can be used to customize your hackmd installation.                                                                                                                                                                                               | `{}`                                      |
| **Database**                                               |                                                                                                                                                                                                                                                                               |                                           |
| `database.type`                                            | If external database is used, set it to `external`                                                                                                                                                                                                                            | `internal`                                |
| `database.internal.image.repository`                       | Repository for database image                                                                                                                                                                                                                                                 | `dockerhub.azk8s.cn/sameersbn/postgresql` |
| `database.internal.image.tag`                              | Tag for database image                                                                                                                                                                                                                                                        | `10-2`                                    |
| `database.internal.password`                               | The password for database                                                                                                                                                                                                                                                     | `changeit`                                |
| `database.internal.podAnnotations`                         | Annotations to add to the database pod                                                                                                                                                                                                                                        | `{}`                                      |
| `database.internal.resources`                              | The [resources] to allocate for container                                                                                                                                                                                                                                     | undefined                                 |
| `database.internal.nodeSelector`                           | Node labels for pod assignment                                                                                                                                                                                                                                                | `{}`                                      |
| `database.internal.tolerations`                            | Tolerations for pod assignment                                                                                                                                                                                                                                                | `[]`                                      |
| `database.internal.affinity`                               | Node/Pod affinities                                                                                                                                                                                                                                                           | `{}`                                      |
| `database.external.host`                                   | The hostname of external database                                                                                                                                                                                                                                             | `192.168.0.1`                             |
| `database.external.port`                                   | The port of external database                                                                                                                                                                                                                                                 | `5432`                                    |
| `database.external.username`                               | The username of external database                                                                                                                                                                                                                                             | `user`                                    |
| `database.external.password`                               | The password of external database                                                                                                                                                                                                                                             | `password`                                |
| `database.external.databaseName`                           | The database used by hackmd                                                                                                                                                                                                                                                   | `hackmdhq_production`                     |

[resources]: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/
[available options]: https://github.com/sameersbn/docker-hackmd#available-configuration-parameters