# Kubernetes Demos

## Introduction
This repo contains a number of simple scenarios that help demonstrate Kubernetes concepts and tools.  See the README file in each subdirectory for more information on running each scenario.

## Prerequisites
All scenarios in this repo require PowerShell Core, as this allows you to run them on either Windows or Linux.

## List of scenarios by function

### Getting Started

| Folder | Description
|---|---|
| install-aws-cli | Install and configure the AWS CLI tool.  This is required for any scenarios specific to EKS. |
| install-azure-cli | Install and configure the Azure CLI tool.  This is required to create and manage an AKS cluster. |
| install-gcloud-cli | Install and configure the Google CLI tool.  This is required to create and manage a GKE cluster. |
| install-eksctl | Install the EKSCTL utility.  This is used to create and manage an EKS cluster. |
| export-kubeconfig | Recreate your kubeconfig file if it becomes corrupted or is pointing to the wrong cluster.  kubeconfig is used by kubectl to connect to your cluster. |

### Building a Cluster

| Folder | Description
|---|---|
| eksctl-create-cluster-with-autoscaler | Build an EKS cluster using EKSCTL with cluster autoscaler enabled. |
| eksctl-create-cluster-with-karpenter | Build an EKS cluster using EKSCTL with Karpenter deployed as the node autoscaler. |
| aks-create-cluster-with-autoscaler | Build an AKS cluster using the Azure CLI tool with cluster autoscaler enabled. |
| gke-create-cluster-with-autoscaler | Build a GKE cluster using the Google CLI tool with cluster autoscaler enabled. |

### Pod Placement

| Folder | Description
|---|---|
| assigning-pods-to-nodes | Assign pods to specific nodes by hard coding, nodeSelector, or node affinity. |
| taints-and-tolerations | Drive pods away from certain nodes using taints.  Use taints, tolerations, and node affinity together for powerful, fine-grained control of pod placement on nodes. |

### Observability

| Folder | Description
|---|---|
| install-kube-prometheus-stack | Install kube-state-metrics, node exporter, Prometheus, Grafana, and several Grafana dashboard using the kube-prometheus-stack Helm chart |