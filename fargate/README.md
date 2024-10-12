# Adding a Fargate profile

## Introduction
This is a simple scenario that demonstrates how to add a Fargate profile to an existing EKS cluster.

## Prerequisites
1. Any functional Kubernetes cluster
2. PowerShell Core
3. AWS CLI installed and configured
4. eksctl installed

## Scenario
1. With your cluster already deployed and working, run the following command:

      eksctl create fargateprofile --namespace fargate --cluster <your cluster name> --name fargate-profile  

This will create a Fargate profile where any workload deployed to the "fargate" namespace will be executed on Fargate nodes. 

2. Test a normal deployment.  This will not run in Fargate:

        kubectl create ns testing
        kubectl apply -f php-apache.yaml -n testing
        ./Get-Pods-By-Node.ps1 -n testing

You will see 4 replicas of php-apache running, all on normal K8s nodes.

3. Delete the test deployment and re-deploy it in the fargate namespace:

        kubectl delete ns testing
        kubectl create ns fargate
        kubectl apply -f php-apache.yaml -n fargate

Wait a few minutes for the workload to deploy.  Run 

        kubectl get po -n fargate

to check status of the deployment.  When all pods enter a "running" state the deployment is complete.

4. Confirm your workload is running on Fargate nodes:

        ./Get-Pods-By-Node.ps1 -n fargate
        kubectl get no

You will see that all 4 replicas in your deployment are running on separate Fargate nodes.

6. When done, delete your workload and Fargate profile by running:

        kubectl delete ns fargate
        eksctl delete fargateprofile --cluster <your cluster name> --name fargate-profile