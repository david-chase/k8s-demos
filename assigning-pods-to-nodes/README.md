# Assigning pods to nodes

## Introduction
There are numerous ways to assign pods to run on certain nodes and this scenario will demonstrate three of them:

* Hard coding a node name
* Node selector with labels
* Node affinity

Assigning certain pods to run on certain nodes is part of any complex Kubernetes deployment and can be done to ensure pods run on nodes that have specialized hardware they require (like GPUs), to make sure a team's workloads run on the nodes they're paying for (and no one else's), to prevent expensive cross-zone network traffic, to ensure a fault-tolerant cluster, and more.

## Prerequisites
1. A functional Kubernetes cluster with at least 3 nodes
2. PowerShell Core

You can use any of the cluster creation scenarios in this repo to create your 3-node K8s cluster simply by editing config.ini and setting "minsize" to 3.

## Scenario
### Before we begin
Before we begin, let's see how pods in a deployment are distributed across nodes by default.  

1. Deploy a workload that does no pod assignment

        kubectl apply -f php-apache.yaml

2. Check what node(s) the pods have been placed on:

        ./Get-Pods-By-Node.ps1 -n testing

You will notice the default is to spread the pods evenly across the available nodes.  If you have 3 nodes and 3 replicas, one replica will be placed on each node.

3. Delete the workload

        kubectl delete -f php-apache.yaml

### Hard coding a node name
This is generally not recommended but is a quick and simple way to assign pods to a node.  This actually bypasses the kubernetes scheduler, with the kubelet running on the node actually starting the pods.

1. Get a list of the nodes in your cluster.

        kubectl get no

2. Edit php-apache-hardcoded.yaml and replace "\<your node name\>" with one of the nodes in your cluster.

3. Deploy the workload.

        kubectl apply -f php-apache-hardcoded.yaml

4. Check what node(s) the pods have been placed on:

        ./Get-Pods-By-Node.ps1 -n testing

Instead of spreading the replicas evenly across nodes, all 3 replicas will be placed on the node you specified in the YAML file.

5. When done, delete your workload:

        kubectl delete -f php-apache-hardcoded.yaml

### Node selector with labels
This scenario tells the pods in a deployment to only deploy on nodes with certain labels assigned to them.

Deploy a test workload to your cluster.

    kubectl apply -f php-apache-nodeselector.yaml

If you edit php-apache-nodeselector.yaml with a text editor you will see it creates two deployments of 3 replicas each.  Notice that each deployment has a NodeSelector section:

    ...
    # Create a Deployment
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: prodapp
    ...
    spec:
      # These pods will only be placed on nodes where "node-restriction.kubernetes.io/env" = "prod"
      nodeSelector:
        node-restriction.kubernetes.io/env : prod
    ...
    # Create a Deployment
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: devapp
    ....
    spec:
      # These pods will only be placed on nodes where "node-restriction.kubernetes.io/env" = "dev"
      nodeSelector:
        node-restriction.kubernetes.io/env : dev

Let's check the status of our deployment:

    kubectl get po -n testing

Notice that all of our pods are in Pending status because there are no nodes with matching labels.  Let's change that. Run

    kubectl get no

to see a list of nodes in our cluster.  Run the following command for *one* of the nodes:

    kubectl label node <first node name> node-restriction.kubernetes.io/env=prod

Now run the following command for a *different* node:

    kubectl label node <second node name> node-restriction.kubernetes.io/env=dev

Let's check the status of our pods again

    kubectl get po -n testing

All our pods are now in a running state.  Let's confirm they're running on the nodes we've deployed labels to:

    ./Get-Pods-By-Node.ps1 -n testing

Notice that the "prodapp" pods are all running on the node we labeled as "prod" while the "devapp" pods are running on the node we labeled as "dev".  When done, delete your deployment by running

    kubectl delete -f php-apache-nodeselector.yaml

### Node affinity and anti-affinity
Let's temporarily remove the node labels we created in the previous exercise so we can see how node affinity differs from NodeSelector.

    kubectl label node <first node name> node-restriction.kubernetes.io/env= --overwrite
    kubectl label node <second node name> node-restriction.kubernetes.io/env= --overwrite

Deploy a test workload to your cluster.

    kubectl apply -f php-apache-affinity.yaml

If you edit php-apache-nodeselector.yaml with a text editor you will see it creates three deployments of 3 replicas each.  The first deployment asks to be placed on nodes where the label node-restriction.kubernetes.io/env has the value "prod", the second where it has the value "dev" and the third asks to be placed on nodes with no node-restriction.kubernetes.io/env label at all. 

Let's check the status of our deployment:

    kubectl get po -n testing

Notice that unlike in the previous exercise, all the pods are scheduled even though none of our nodes are labeled.  This is because we specified "preferredDuringSchedulingIgnoredDuringExecution" in our YAML manifest.  However if you run "Get-Pods-By-Node.ps1 -n testing" you'll notice the pods were placed without any order.

Let's delete this deployment, label our nodes again, and redeploy:

    kubectl delete -f php-apache-affinity.yaml
    kubectl label node <first node name> node-restriction.kubernetes.io/env=prod
    kubectl label node <second node name> node-restriction.kubernetes.io/env=dev
    kubectl apply -f php-apache-affinity.yaml

Now let's check how our pods have been placed:

    ./Get-Pods-By-Node.ps1 -n testing

As expected, the "prodapp" pods are all running on the node we labeled as "prod", the "devapp" pods are running on the node we labeled as "dev", and the "nolabel" pods are running on the node with no "node-restriction.kubernetes.io/env" label at all.

When done, delete your deployment and unlabel your nodes:

    kubectl delete -f php-apache-affinity.yaml
    kubectl label node <first node name> node-restriction.kubernetes.io/env= --overwrite
    kubectl label node <second node name> node-restriction.kubernetes.io/env= --overwrite
