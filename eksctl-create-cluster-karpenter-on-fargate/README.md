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
https://github.com/david-chase/k8s-demos/tree/master/install-aws-cli

For instructions on installing eksctl see:
https://github.com/david-chase/k8s-demos/tree/master/install-eksctl

## Third-party Tools
This scenario includes a copy of the envsubst tool which can be found here:

https://github.com/a8m/envsubst

It is released under the [MIT license](https://github.com/a8m/envsubst/blob/master/LICENSE).

## Scenario

1. Set your cluster preferences by editing config.ini
2. Start by running 

        Build-Cluster.ps1
        
This script will take 15-25 minutes to execute and will provision everything for you.  Try to avoid halting the script in mid-execution as doing so may leave some vestiges behind that must be cleaned up manually.

The script will show you all the commands it's running, and don't hesitate to open the script in a text editor to see how it works.

3. Check how many nodes are part of your cluster by typing 

        kubectl get no
        
You should see several nodes running, all of them prefixed with "fargate".

4. Check what pods are running on what nodes

        .\Get-Pods-By-Node -n kube-system

This will show that Karpenter, and some parts of the Kubernetes control plane are running on Fargate.

5. Let's deploy some workloads and see Karpenter in action.  Start your test deployment by typing

        kubectl apply -f php-apache.yaml

Wait until the pod is in Ready state.  You can check this by running

    kubectl get po -n testing -w

The -w switch tells kubectl to keep running, and show you updates as they happen.  Once you see a status message showing the pod is in Ready state, hit Ctl-C to return to the command prompt.

6. Check how and where your deployment is running by typing 

        .\Get-Pods-By-Node.ps1 -n testing
    
Notice that your single pod is running on a regular Karpenter-provisioned node, not a Fargate node.  The only workload(s) we want running on Fargate are Karpenter and portions of our control plane.

7. Scale up your deployment to add more replicas by typing 

        kubectl scale deploy php-apache -n testing --replicas=25

Let's check the status of our deployment by typing:

    kubectl get po -n testing -w

Hit Ctl-C when all pods have entered a Running state.

8. See all the pods in your deployment and the nodes they're running on.

        .\Get-Pods-By-Node.ps1 -n testing

9. Go to the AWS console and find your EKS cluster.  Click on it to see properties then click the "Compute" tab to see any nodes assigned to it.  Note that the first node created will be part of a managed node group and should be running on a t3.medium instance.  Any nodes that aren't in a node group were scaled out by Karpenter.

10. Click on one of the Karpenter nodes, then scroll down to Labels, and find the label karpenter.sh/capacity-type.  This will read either "on demand" or "spot".  Note that the instance type can be any one of many.  The allowable instance types are defined in nodepool.yaml.

<img src="https://i.imgur.com/74AtlHK.png" width=500>

11. Scale your deployment back down and see what happens with the nodes by typing

        kubectl scale deploy php-apache -n testing --replicas=1
        
After a few minutes you should start seeing the Karpenter nodes disappear.

12. When you've finished your testing, deprovision the resources by running Destroy-Cluster.ps1.  This will take several minutes.
