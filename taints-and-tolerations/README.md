# Assigning pods to nodes

## Introduction
In the [assigning pods to nodes](https://github.com/dbc13543/k8s-demos/tree/master/assigning-pods-to-nodes) exercise we learned about node selectors and node affinity as ways of assigning pods to specific nodes.  However while these methods are effective at forcing certain workloads onto specific nodes, what they don't do is *prevent unwanted pods* from running on those nodes.  This is where taints and tolerations come in.

Taints are applied to nodes as key/value pairs.  Tainted nodes will repel all pods that do not have a matching toleration.  In this way they provide better control of pod placement, as *only* the pods you want can be applied to a tainted node.

Remember: Taints are applied to nodes, tolerations are applied to pods.

## Prerequisites
1. A functional Kubernetes cluster with at least 3 nodes
2. PowerShell Core

You can use any of the scenarios in this repo to create your 3-node K8s cluster simply by editing config.ini and setting "minsize" to 3.

## Scenario
### Before we begin
Before we begin, let's see how pods in a deployment are distributed across nodes by default.  

1. Deploy a workload that does no pod assignment

        kubectl apply -f php-apache.yaml

2. Check what node(s) the pods have been placed on:

        ./Get-Pods-By-Node.ps1 -n testing

You will notice the default is to spread the pods evenly across the available nodes.  If you have 3 nodes and 3 replicas, one replica will be placed on each node.  Leave th

### Tainting nodes

1. Get a list of the nodes in your cluster

        kubectl get no

2. Apply a taint to one of the nodes

        kubectl taint node \<node name\> disktype=SSD:NoExecute

The ":NoExecute" portion of this command line is known as the effect.  A "NoExecute" effect means that any pods running on the node that do not match this taint cannot even execute on the node and will be immediately evicted.  A "NoSchedule" effect means existing pods running on the node may continue to run, but new pods won't be scheduled unless they have a matching toleration.

3. Check again what pods are running on which nodes:

        ./Get-Pods-By-Node.ps1 -n testing

You will notice that the pod that was running on the node you just tainted has been moved to a different node.  This is because the pod has no toleration to match the taint you just placed on the node.

4. Apply a second taint to a *different* node

        kubectl taint node \<node name\> GPU=true:NoExecute

5. Check again what pods are running on which nodes:

        ./Get-Pods-By-Node.ps1 -n testing

As expected, all the pods in our test workload have now been moved to the only node without a taint.  

6. Edit the file php-tolerations.yaml with a text editor.  Note the following two sections:

                ...
                tolerations:
                - key: "disktype"
                  operator: "Equal"
                  value: "SSD"
                  effect: "NoExecute"
                ...
                tolerations:
                - key: "GPU"
                  operator: "Equal"
                  value: "true"
                  effect: "NoExecute"
                ...

Notice that one of our deployments has a toleration that matches the first taint we applied to a node.  The second deployment has a toleration that matches the second taint we applied.  In this scenario we're simulating some pods being forced onto nodes that have a local attached SSD, and others being forced onto nodes that have a GPU.  

Keep in mind that the key, operator, values, and effect of a toleration must match the taint applied to the node.  This means that if the taint you applied to the node has a "NoSchedule" effect but the toleration applied to the pods is "NoExecute", then the taints and tolerations do not match and the pods will not be scheduled on the tainted node.

7. Let's deploy pods that have tolerations defined.

        kubectl apply -f php-apache-tolerations.yaml


8. Check again what pods are running on which nodes:

        ./Get-Pods-By-Node.ps1 -n testing

You should find that only pods with a matching toleration have been scheduled on the GPU node, and only the pods with a matching toleration have been scheduled on the SSD nodes.  *However*, it's possible you may see some pods with tolerations assigned to them scheduled on the node that has no taints.  Why is that?

It's because adding a toleration to a pod merely says that it's *capable* of running on a node with a matching taint, not that it *must*.  If you want certain pods to *only* run on tainted nodes and no other, you can do this by combining taints, tolerations, and node affinity.

### Taints, tolerations, and node affinity
Let's complete a few more steps to ensure that:

* Pods with no tolerations only execute on the node with no taints
* Pods with a toleration of "disktype=SSD" only run on nodes with a "disktype=SSD" taint
* Pods with a toleration of "GPU=true" only run on nodes with a "GPU-true" taint

1. Delete the workload we just deployed and redeploy the "vanilla" workload that has no tolerations.

        kubectl delete -f php-apache-tolerations.yaml
        kubectl apply -f php-apache.yaml

2. Apply labels to our tainted nodes.  If you're having trouble remembering which nodes have which taints, simply run the following:

        kubectl describe node \<node name\> | Select-String "Taint"

On the node with the "disktype=SSD" taint:

        kubectl label node \<node name\> disktype=SSD

On the node with the "GPU=true" taint:

        kubectl label node \<node name\> GPU=true

3. Edit php-apache-tolerations-and-node-affinity.yaml with a text editor.  Notice that in our two deployments we now have a section that defines a toleration (these pods *can* run on nodes with a matching taint) and a node affinity (these pods *must* run on a node with the following labels).

4. Deploy the workload

        kubectl deploy -f php-apache-tolerations-and-node-affinity.yaml

5. Check again what pods are running on which nodes:

        ./Get-Pods-By-Node.ps1 -n testing

This should look very similar to the previous scenario, but with an important difference.  In the previous scenario our pods with tolerations *could* run on an untainted node.  In this scenario we're forcing them to run on a particular node, and none other.

6. Let's undo our changes by deleting our workloads, and removing our node labels and taints.  

        kubectl delete -f php-apache-tolerations-and-node-affinity.yaml
        kubectl label node \<node name\> GPU= --overwrite
        kubectl label node \<node name\> disktype= --overwrite
        kubectl taint node \<node name\> GPU=true:NoExecute-
        kubectl taint node \<node name\> disktype-SSD:NoExecute-

If you're having trouble remembering which nodes have which labels and taints applied, try these helpful commands:

        kubectl get no -l GPU=true
        kubectl get no -l disktype=SSD
        kubectl get nodes -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints

Done!
