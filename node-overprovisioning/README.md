# Node Overprovisioning

## Introduction
For mission critical environments where highly responsive workloads are required, the simple act of scaling out a node can cause excessive delays as pods wait for a new node to launch.  To avoid this scenario we do node overprovisioning.

This entails ensuring there is always one more node provisioned than we actually need.  We do this by placing a large, low priority "placeholder" pod in the cluster that is the size of one node.  When a new production workload comes online and finds there isn't sufficient capacity in the cluster to place the workload, the Kubernetes scheduler evicts the low-priority placeholder pod immediately and schedules the production pod on the node it was running on, meaning your production workload is provisioned nearly instantly.  The placeholder pod now has nowhere to run and the autoscaler scales out a new node for it to run on.  The placeholder pod suffers the latency of scaling out a new node, not your production workload.

This scenario is based on information in this article:

https://medium.com/adevinta-tech-blog/the-karpenter-effect-redefining-our-kubernetes-operations-80c7ba90a599

## Prerequisites
1. A functional Kubernetes cluster with exactly 1 node and a node autoscaler enabled
2. PowerShell Core

You can use any of the "create-cluster-with-autoscaler" scenarios in this repo to create your single-node K8s cluster simply by editing config.ini and setting "minsize" to 1.

## Scenario
1. Check the current configuration of your Kubernetes cluster:

        kubectl get no

There should be only one node running.  Copy its name to the clipboard.

2. We need to find out how many placeholder pods need to run in our cluster to fill one node.  Start by running

        kubectl describe node <node name>

Search for the following section and take note of the Allocatable CPU:

    Allocatable:
      cpu:                1930m
      ephemeral-storage:  76224326324
      hugepages-1Gi:      0
      hugepages-2Mi:      0
      memory:             7265164Ki
      pods:               17

Since there will be 5 pods in our placeholder deployment, divide the allocatable CPU by 5 and round down to the next whole number.  In this example 1930 / 5 = 386.

3. Edit placeholder.yaml to set the CPU requests to this value:

        resources:
                requests:
                cpu: 386m

This means that at all times this deployment will be requesting one whole node in capacity.

4. Deploy the placeholder deployment

        kubectl apply -f placeholder.yaml

Check the status of the deployment by running

        kubectl get pod -n testing

Wait until all pods are in a Ready state.  This may take some time as a node will need to be added to your cluster.  

5. Once all pods are Ready, confirm that there are two nodes running:

        kubectl get no

Notice that we now have two nodes running.  One where any existing pods and workloads are running, and a second placeholder node to handle any bursts in demand.

6. Simulate a new production workload coming online:

        kubectl apply -f php-apache.yaml

Then immediately start monitoring the status of the deployment by running:

        kubectl get po -n testing

Repeat this command several times.  You should see the php-apache pods entering a Ready state fairly quickly, while the placeholder pods actually drop into a Pending state as they are evicted to make room for the production workload.  Eventually the placeholder pods will return to a Ready state after sufficient nodes have been scaled out to handle the new production workload *and* one "spare" node.

NOTE: This process will be easier to see in action if you use a GUI-based Kubernetes tool like Kubernetes Dashboard, Kubeview, Lens, or Octant.

7. Check how many nodes have been provisioned.  

        kubectl get no

It should correspond to the total number of nodes required to run your workloads, plus one spare.  

We have now demonstrated an "N+1" node allocation strategy, where there is always one node ready and waiting to accept new workloads.  This prevents your production workloads from suffering latency when new nodes need to be added to the cluster.

This concludes the scenario.