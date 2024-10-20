# Pod Disruption Budgets

## Introduction
Pod disruption budgets are an invaluable tool for high-availability Kubernetes implementations.  They prevent workloads from being interrupted by routine maintenance by ensuring some pods in your workload are always running.  

For example, imagine you have a critical workload that consists of 9 pods.  You could define a PDB that ensures at least 3 pods are running at all time, regardless of planned maintenance.  If you restart this workload with the PDB in place, Kubernetes will restart 6 pods right away, but leave 3 running to satisfy the pod disruption budget.  As the restarted pods come back online, the remaining 3 pods will be restarted.

In this scenario we will simulate a critical workload where every replica is running on a single node.  An admin inadvertently attempts to bring this node offline for maintenance.  We'll see what happens both with, and without, a PDB in place.

## Prerequisites
1. A working Kubernetes cluster

## Scenario
1. In this scenario we only want to use a single node, so we will disable cluster autoscaler and taint all the nodes in our cluster except one.

If you are using cluster autoscaler, disable it by running

    kubectl scale deploy cluster-autoscaler -n kube-system --replicas=0

If you have multiple nodes, run the following on every node but one

    taint node <node name> nodepaused:NoExecute

2. Now deploy your workload:

        kubectl apply -f php-apache.yaml

3. Check the status of your deployment:

        ./Get-Pods-By-Node.ps1 -n testing

You should see 7 pods running, all on your untainted node.

4. Let's simulate accidentally taking down this node for maintenance

        kubectl drain <node name> --ignore-daemonsets --delete-emptydir-data

You should see all of your testing pods being evicted.  If you're running this scenario on the same node where your control plane is running you will see a number of errors saying 'error when evicting pods XXX -n "kube-system" (will retry after 5s).'  If you do, simply press Ctl-C to stop the process from retrying over and over.  (You will not see these errors if you're running this scenario on a different node than the one with running the Kubernetes control plane.)

NOTE: The cool thing about this error is, it's actually Pod Disruption Budgets that are preventing you from terminating these kube-system pods!  

5. Check the status of your deployment:

        ./Get-Pods-By-Node.ps1 -n testing

You will notice that all of your pods were terminated.  If this was a mission-critical workload, then your application would be experiencing a full service outage!

6. Let's return the node to it's original state:

        kubectl uncordon <node name>
        ./Get-Pods-By-Node.ps1 -n testing

You should see your workload return to its original, healthy state.  

7. Deploy a pod disruption budget

        kubectl apply -f .\pdb.yaml

Our PDB specifies that at least 3 pods in our deployment must be running at all times.  Let's simulate that administrator accidentally taking the node down for maintenance again.  Will he ever learn?

        kubectl drain <node name> --ignore-daemonsets --delete-emptydir-data

You should observe many of your pods being evicted.  However at some point you should enter a loop telling you some pods could not be evicted, retrying in 5s.  At this point hit Ctl-C to stop the loop.

5. Check the status of your deployment:

        ./Get-Pods-By-Node.ps1 -n testing

You will see 3 pods still running, just as we set in our pod disruption budget.  Our critical workload didn't go down because of a mistake during routine maintenance.  Crisis averted!

6. When ready, roll back your changes:

        kubectl uncordon <node name>
        kubectl delete -f pdb.yaml
        kubectl delete -f php-apache.yaml

If you tainted any extra nodes, untaint them now

    taint node <node name> nodepaused:NoExecute-

If you paused cluster autoscaler, you can resume it now

    kubectl scale deploy cluster-autoscaler -n kube-system --replicas=1

This concludes the scenario.
