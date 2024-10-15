# Create a test cluster with EKSCTL and Karpenter

## Introduction
This scenario will build an EKS cluster using the eksctl utility and deploy Karpenter as your autoscaler. 

Note that there is roughly a $70USD monthly fee to run the control plane, plus the cost of the managed node group, so you will probably want to destroy this cluster after you're finished with it.

This scenario is based on the "Getting Started With Karpenter" tutorial at https://karpenter.sh/docs/getting-started/getting-started-with-karpenter/

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

1. Start by running 

        Build-Cluster.ps1
        
This script will take 15-25 minutes to execute and will provision everything for you.  Try to avoid halting the script in mid-execution as doing so may leave some vestiges behind that must be cleaned up manually.

The script will show you all the commands it's running, and don't hesitate to open the script in a text editor to see how it works.

2. Check how many nodes are part of your cluster by typing 

        kubectl get no
        
You'll notice there is one node running at all times.  Karpenter requires at least one node be created first, to host kube-system components and karpenter itself.  This first node is NOT managed by Karpenter but is instead just a regular EKS Managed Node Pool with a single node.

4. Let's see some autoscaling in action.  Start your test deployment by typing

        kubectl apply -f php-apache.yaml

5. Check how and where your deployment is running by typing 

        .\Get-Pods-By-Node.ps1 -n testing
    
You'll notice only a single pod running in the "testing" namespace on your single node.

6. Scale up your deployment to add more replicas by typing 

        kubectl scale deploy php-apache -n testing --replicas=25

Let's check the status of our deployment by typing:

    kubectl get po -n testing

You should see some pods in a Pending state because we don't have enough node capacity for every replica.  Check if nodes are being provisioned by typing:

    kubectl get no

You may see a node in the process of being provisioned.  Continue to run these two commands until we see all pods in a Running state and all nodes are Ready.

8. See all the pods in your deployment and the nodes they're running on.

        .\Get-Pods-By-Node.ps1 -n testing

9. Go to the AWS console and find your EKS cluster.  Click on it to see properties then click the "Compute" tab to see any nodes assigned to it.  Note that the first node created will be part of a managed node group and should be running on a t3.medium instance.  Any nodes that aren't in a node group were scaled out by Karpenter.

10. Click on one of the Karpenter nodes, then scroll down to Labels, and find the label karpenter.sh/capacity-type.  This will read either "on demand" or "spot".  Note that the instance type can be any one of many.  The allowable instance types are defined in nodepool.yaml.

<img src="https://i.imgur.com/74AtlHK.png" width=500>

11. Scale your deployment back down and see what happens with the nodes by typing

        kubectl scale deploy php-apache -n testing --replicas=1
        
After a few minutes you should start seeing the Karpenter nodes disappear.

12. When you've finished your testing, deprovision the resources by running Destroy-Cluster.ps1.  This will take several minutes.
