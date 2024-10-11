# Create a test cluster with Azure CLI and cluster autoscaler

## Introduction
This scenario will build an AKS cluster using the Azure CLI utility and deploy cluster autoscaler.  AKS does not support building clusters with no worker nodes, so this scenario will build the cluster and a nodepool simultaneously.

## Prerequisites
1. Azure CLI installed and configured
2. PowerShell Core

For instructions on installing and configuring the Azure CLI see:
https://github.com/dbc13543/k8s-demos/tree/master/install-azure-cli

## Scenario

1. Set your cluster preferences by editing config.ini
2. Deploy the cluster by running:

        .\Build-Cluster.ps1

This will take several minutes and will make a sound when it's complete.

3. Confirm you have at least one worker node running:

        kubectl get no

4. Try deploying a workload to your cluster

        kubectl apply -f php-apache.yaml

5. Check the status of your deployment

        kubectl get po -n testing

You should see a single pod running in the "testing" namespace.

6. Confirm cluster autoscaler is working by scaling up your test deployment

        kubectl scale deploy php-apache -n testing --replicas=18

10. Watch the cluster scale out and deploy pods by running the following commands multiple times until there are no more pods in "Pending" state:

        .\Get-Pods-By-Node.ps1 -n testing
        kubectl get pods -n testing | Select-String "Pending"

You should see the first node fill quite quickly and all pods on this node enter "Running" state.  However several pods will remain in "Pending" status until cluster autoscaler has added enough capacity.  This should take 1-3 minutes.  Your cluster will likely scale out to 2 nodes and all pods will enter "Running" state. 

11. Scale your deployment back down 

        kubectl scale deploy php-apache -n testing --replicas=1

You should be able to observe your nodes scaling back in by occasionally running:

    kubectl get no

It should take 10-15 minutes before your cluster scales back down to a single node.

12. When done all testing, deprovision the cluster and its worker nodes by running:

        .\Destroy-Cluster.ps1
