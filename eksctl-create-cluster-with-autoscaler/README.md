# Create a test cluster with EKSCTL and cluster autoscaler

## Introduction
This scenario will build an EKS cluster using the eksctl utility and deploy cluster autoscaler.  The control plane and worker nodes are provisioned in separate steps, so you can deprovision your worker nodes when they're not in use.  When you need to use your cluster again, simply provision worker nodes again and your workloads will resume where they left off.

Note that there is roughly a $70USD monthly fee to run the control plane, so deprovisioning your worker nodes merely *reduces* your monthly costs, it does not eliminate them.

## Prerequisites
1. AWS CLI installed and configured
2. EKSCTL installed
3. PowerShell Core

For instructions on installing and configuring the AWS CLI see:
https://github.com/dbc13543/k8s-demos/tree/master/install-aws-cli

For instructions on installing eksctl see:
https://github.com/dbc13543/k8s-demos/tree/master/install-eksctl

## Third-party Tools
This scenario includes a copy of the envsubst tool which can be found here:

https://github.com/a8m/envsubst

It is released under the [MIT license](https://github.com/a8m/envsubst/blob/master/LICENSE).

## Scenario

1. Set your cluster preferences by editing config.ini
2. Deploy the cluster by running:

    .\Build-Cluster.ps1

This will take several minutes and will make a sound when it's complete.

3. Confirm there are no worker nodes in your cluster:

    kubectl get no

4. Try deploying a workload to your cluster

    kubectl apply -f php-apache.yaml

5. Check the status of your deployment

    kubectl get po -n testing

You should observe a single pod in the "testing" namespace that is stuck in "Pending" status.  This is because there are no worker nodes to run the workload.

6. Provision a managed nodegroup and deploy cluster autoscaler by running:

    .\Add-Nodegroup.ps1

This will take several minutes and will make a sound when it's complete.

7. Confirm you have at least one worker node running:

    kubectl get no

8. Confirm your test workload is now running:

    kubectl get po -n testing

You should observe that the pod is no longer in a "Pending" state.

9. Confirm cluster autoscaler is working by scaling up your test deployment

    kubectl scale deploy php-apache -n testing --replicas=18

10. Watch the cluster scale out and deploy pods by running the following commands multiple times until all pods are in a "Running" state:

    .\Get-Pods-By-Node.ps1 -n testing
    kubectl get pods -n testing

You should see the first node fill quite quickly and all pods on this node enter "Running" state.  However several pods will remain in "Pending" status until cluster autoscaler has added enough capacity.  This should take 1-3 minutes.  Your cluster will likely scale out to around 3 nodes and all pods will enter "Running" state. 

11. Scale your deployment back down 

    kubectl scale deploy php-apache -n testing --replicas=1

You should be able to observe your nodes scaling back in by occasionally running:

    kubectl get no

It should take 10-15 minutes before your cluster scales back down to a single node.

12. When done, deprovision your managed node group by running:

     .\Destroy-Nodegroup.ps1

You can leave your cluster in this state if you wish to use it again in the future.  Simply run "Add-Nodegroup.ps1" again to provision more worker nodes.  If you no longer need the test cluster you can delete it by proceeding to the next step.

13. To deprovision the control plane and delete the cluster run:

    .\Destroy-Cluster.ps1

## Scaling the Nodegroup
With cluster autoscaler deployed, nodes will automatically be added to your nodegroup if you run out of capacity.  However in some situations you may like to directly change the number of nodes in your cluster.  For example, to ensure you have at least 3 nodes in your cluster, run the following scripts:

    .\Scale-Nodegroup.ps1 -nodes <numnodes>

This will scale your cluster up (or in some situations down) to three nodes.  To verify the scaling was successful, run:

    kubectl get no
