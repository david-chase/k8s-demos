# Assigning pods to nodes

## Introduction
There are numerous ways to assign pods to run on certain nodes and this scenario will demonstrate most of them including:

* Hard coding a node name
* Node selectors with labels
* Node affinity and anti-affinity
* Taints and tolerations
* Pod topology spread constraints

Assigning certain pods to run on certain nodes is part of any complex Kubernetes deployment and can be done to ensure pods run on nodes that have specialized hardware they require (like GPUs), to make sure a team's workloads run on the nodes they're paying for (and no one else's), to prevent expensive cross-zone network traffic, to ensure a fault-tolerant cluster, and more.

## Prerequisites
1. A functional Kubernetes cluster with at least 3 nodes
2. PowerShell Core

You can use any of the scenarios in this repo to create your 3-node K8s cluster simply by editing config.ini and setting "minsize" to 3.

## Scenario
### Hard coding a node name
This is generally not recommended but is a quick and simple way to assign pods to a node.  This actually bypasses the kubernetes scheduler, with the kubelet running on the node actually starting the pods.

1. Get a list of the nodes in your cluster.

        kubectl get no

2. Edit php-apache-hardcoded.yaml and replace '<your node name>' with one of the nodes in your cluster.

3. Deploy the workload.

        kubectl apply -f php-apache-hardcoded.yaml

4. Check what node(s) the pods have been placed on:

        ./Get-Pods-By-Node.ps1 -n testing

5. When done, delete your workload:

        kubectl delete -f php-apache-hardcoded.yaml

### Node selectors with labels
This scenario tells the pods in a deployment to show a preference for nodes with certain labels assigned to them.

