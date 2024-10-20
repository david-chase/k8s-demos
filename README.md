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
| eksctl-create-cluster-karpenter-on-fargate | Build an EKS cluster where Karpenter runs on Fargate.  **COMING SOON** |
| aks-create-cluster-with-autoscaler | Build an AKS cluster using the Azure CLI tool with cluster autoscaler enabled. |
| gke-create-cluster-with-autoscaler | Build a GKE cluster using the Google CLI tool with cluster autoscaler enabled. |

### Pod Placement

| Folder | Description
|---|---|
| assigning-pods-to-nodes | Assign pods to specific nodes by hard coding, nodeSelector, or node affinity. |
| taints-and-tolerations | Drive pods away from certain nodes using taints.  Use taints, tolerations, and node affinity together for powerful, fine-grained control of pod placement on nodes. |
| bin-packing-mostallocated | Use bin packing in EKS, AKS, and GKE by deploying a custom scheduler with MostAllocated node scoring algorithm enabled. |
| pod-affinity | Ensure related workloads get deployed together on the same nodes using pod affinity.  **COMING SOON** |


### Pod Autoscaling

| Folder | Description
|---|---|
| horizontal-pod-autoscaler | Scale workloads by adding replicas using Horizontal Pod Autoscaler. |
| vertical-pod-autoscaler | Scale workloads by allocating more resources to them using Vertical Pod Autoscaler.  **COMING SOON** |
| keda-demo | Scale workloads based on application metrics using Kubernetes Event Driven Autoscaler (KEDA). **COMING SOON** |

### High Availability

| Folder | Description
|---|---|
| pod-disruption-budgets | Prevent critical workloads from being impacted by routine maintenance with Pod Disruption Budgets. |
| pod-topology-spread-constraints | Support High Availability Kubernetes implementations by ensuring pods are evenly distributed across availability zones. **COMING SOON** |

### Observability

| Folder | Description
|---|---|
| install-kube-prometheus-stack | Install kube-state-metrics, node exporter, Prometheus, Grafana, and several Grafana dashboard using the kube-prometheus-stack Helm chart |

### Policy

| Folder | Description
|---|---|
| gatekeeper-policy | Use Gatekeeper and OPA to require all pods to have Requests and Limits defined. |
| kyverno-policy | Deploy and use Kyverno to enforce policy in your cluster.  **COMING SOON** |

### Miscellaneous

| Folder | Description
|---|---|
| fargate-profile | Create a Fargate profile for EKS that runs all workloads for a particular namespace on Fargate serverless nodes. |