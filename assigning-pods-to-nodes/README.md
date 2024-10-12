# Assigning pods to nodes

## Introduction
There are numerous ways to assign pods to run on certain nodes and this scenario will demonstrate most of them including:

* Hard coding a node name
* Node selectors with labels
* Node affinity and anti-affinity
* Taints and tolerations
* Pod topology spread constraints



## Prerequisites
1. A functional Kubernetes cluster with at least 3 nodes
2. PowerShell Core

You can use any of the scenarios in this repo to create your 3-node K8s cluster simply by editing config.ini and setting "minsize" to 3.

## Scenario
### Hard coding a node name
This is generally not recommended but is a quick and simple way to assign pods to a node.  This actually bypasses the kubernetes scheduler, with the kubeleter running on the node actually starting the pods.

1. Get a list of the nodes in your cluster.

        kubectl get no

2. Save the following file as php-apache-hardcoded.yaml, replacing <your node name> with the name of one of the nodes in your cluster.

        # Create a Deployment
        apiVersion: apps/v1
        kind: Deployment
        metadata:
        name: php-apache
        namespace: testing
        spec:
        replicas: 3
        selector:
        matchLabels:
        app: demo
        template:
        metadata:
        labels:
                app: demo
        spec:
        containers:
        - name: php-apache
                image: registry.k8s.io/hpa-example
        nodeName: <your node name>

3. Deploy the workload.

        kubectl apply -f php-apache-hardcoded.yaml

4. Check what node(s) the pods have been placed on:

        ./Get-Pods-By-Node.ps1 -n testing

5. When done, delete your workload:

        kubectl delete -f php-apache-hardcoded.yaml