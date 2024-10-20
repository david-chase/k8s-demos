# Pod Topology Spread Constraints

## Introduction
This scenario demonstrates how to evenly spread workloads across nodes based on their geography.  This supports highly available Kubernetes environments, as you can ensure workloads are evenly spread across availability zones.

Note that Kubernetes has no awareness of geography, it simply evenly distributes load across key/value pairs you specify.  You must intelligently label your nodes on creation for Pod Topology Spread Constraints to work.

## Prerequisites
1. A working Kubernetes cluster with at least 2 nodes.

## Scenario
1. Let's start by seeing how 2 deployments get distributed across nodes with no Pod Topology Spread Contraints:

        kubectl apply -f php-apache.yaml

2. See how your workloads have been spread across nodes:

        .\Get-Pods-By-Nodes -n testing

You'll see that pods are evenly distributed across nodes by default.  

3. Delete this deployment.

        kubectl delete -f php-apache.yaml

4. Let's simulate two different nodes being in two differen availability zones.  First let's see a list of all our nodes:

        kubectl get no

5. Apply a label "region=west" to one node

        kubectl label node <node name> region=west

6. Apply a label "region=east" to another node

        kubectl label node <node name> region=east

7. Confirm your labels have been applied

        kubectl get no --show-labels

IMPORTANT: If you created your cluster in any of the major managed Kubernetes services (EKS, AKS, GKE) you should notice there are already topology-related labels deployed to your nodes.  So in the real world you won't even need to deploy labels yourself, this will be done for you.

8. Open php-apache-withconstraints.yaml with a text editor.  You will notice each of our two deployments contain the following section:

        # Use topology spread constraints to say I need to evenly distribute containers across regions
        topologySpreadConstraints:
        - maxSkew: 1
          topologyKey: region
          whenUnsatisfiable: DoNotSchedule
          labelSelector:
            matchLabels:
              app: demo

This tells our deployments to evenly distribute pods based on the value of the "region" label, and to ensure the difference in number (skew) between regions never exceeds 1.

9. Deploy our workload

        kubectl apply -f php-apache-withconstraints.yaml

You will find that the replicas in your deployments will now be evenly distributed across the two nodes you labeled as "east" and "west".  If you have any nodes where no "region" label was assigned, no pods will will be scheduled on them.

This demonstrates how you can force workloads to be evenly distributed across availability zones using node labels that describe the node's location.

10. When done, let's revert our cluster back to its original state

        kubectl delete -f php-apache-withconstraints.yaml
        kubectl label node <first node> region=
        kubectl label node <second node> region=

This concludes the scenario.