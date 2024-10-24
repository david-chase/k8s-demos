# Bin Packing with MostAllocated Node Scoring Algorithm

## Introduction
While bin packing can refer to many things, this scenario focuses on the Kubernetes node scoring algorithm.  By default, when the Kubernetes scheduler is looking for a node to place a pod on it will look at all the nodes that *can* host the workload, and then place it on the *least* busy node.  This node scoring strategy is known as LeastAllocated.

However while this is a low risk algorithm, it can have high associated costs.  It means that it will be very difficult for nodes to scale down in your cluster.  As soon as a node's Requests begins to drop, the scheduler will start placing new workloads on it.  

MostAllocated, on the other hand, is an algorithm that tells the scheduler to place new workloads on the *busiest* node that still has sufficient capacity.  This means that busy nodes stay busy and idle nodes tend to drain and then scale down.  This helps reduce the cost of running many nodes that are only partially utilized, and if your workloads are appropriately sized and optimized, needn't introduce significant risk.  This algorithm is known as bin packing because it packs workloads as tightly as possible on nodes until they reach capacity.

As mentioned, the default node scoring strategy in Kubernetes is LeastAllocated and is configured in the scheduler.  However to complicate matters, none of the managed Kubernetes services -- EKS, AKS, or GKE -- allow you to modify the default Kubernetes scheduler to use the MostAllocated algorithm.  

However, it's actually fairly trivial to deploy a second copy of the Kubernetes scheduler into an EKS, AKS, or GKE cluster that uses the MostAllocated algorithm, then direct your workloads to that scheduler.  This allows you to use bin packing on managed Kubernetes providers, even though it isn't enabled out-of-the-box.

This is what this scenario will demonstrate.

## Prerequisites
1. A functional Kubernetes cluster with at least 3 nodes
2. PowerShell Core

You can use any of the "create-cluster-with-autoscaler" scenarios in this repo to create your 3-node K8s cluster simply by editing config.ini and setting "minsize" to 3.

## Scenario
### Before we begin
Before we begin, let's see how pods in a deployment are distributed across nodes by default.  

1. Deploy a workload that does no pod assignment

        kubectl apply -f php-apache.yaml

2. Check what node(s) the pods have been placed on:

        ./Get-Pods-By-Node.ps1 -n testing

You'll notice the default is to spread the pods evenly across the available nodes.  If you have 3 nodes and 9 replicas, 3 replicas will be placed on each node.  

3. Now that we've seen how the default node scoring algorithm -- LeastAllocated -- works, let's remove this workload and deploy a custom scheduler that uses the MostAllocated algorithm.  Delete this workload

        kubectl delete -f php-apache.yaml

4. Open kustomization.yaml with a text editor.  Notice that it simply tells kubectl to apply a set of manifests in the following order:

        - configmap.yaml
        - serviceaccount.yaml
        - clusterrole.yaml
        - clusterrolebinding.yaml
        - scheduler.yaml

5. Open configmap.yaml with a text editor.  This is the configuration file for our customized Kubernetes scheduler.  You will notice the following section in the file:

        scoringStrategy:
          resources:
          - name: cpu
            weight: 1
          - name: memory
            weight: 1
          type: MostAllocated

The important thing to note is that our node scoring strategy is set to "MostAllocated" and we're weighting CPU and Memory resources equally.

6. Open scheduler.yaml in a text editor.  While it's not vital to understand everything being done in this manifest, the key takeaway is that we're defining a custom scheduler named "my-scheduler".  Since this is not the default scheduler, it will only be used by pods that specify it in their manifests.  We'll demonstrate that soon.

7. Deploy the custom scheduler, using the kustomization.yaml file in the current folder

        kubectl apply -k .

Let's confirm our new scheduler is running

        kubectl get po -n kube-system

You should see a pod running whose name starts with "my-scheduler"

8. Edit php-apache-customscheduler.yaml with a text editor.  Notice that in spec.template.spec we are directing our workload to use the scheduler "my-scheduler".  Without this line our workload will use the default scheduler where bin packing isn't enabled.

9. Now let's deploy our workload

        kubectl apply -f php-apache-customscheduler.yaml

10. Check what node(s) the pods have been placed on:

        ./Get-Pods-By-Node.ps1 -n testing

This time you should see all the pods have been placed on a single node.  This is because our custom scheduler attempts to fill a node to capacity before it moves on to the next node.  If we have an autoscaler enabled (and our minimum group size wasn't 3) then our cluster could scale down to a single node and instead of paying for three nodes with low utilization, we'd instead be paying for one node with high utilization.

11. When ready, let's return our cluster to its previous state.

        kubectl delete -f .\php-apache-customscheduler.yaml
        kubectl delete -k .

This concludes the scenario.
