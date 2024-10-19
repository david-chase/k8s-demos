# Horizontal pod autoscaler

## Introduction
This simple scenario demonstrates how to deploy Horizontal Pod Autoscaler, and how it scales out a deployment when under load.  It is based on the HPA walkthrough found here:

https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/

## Prerequisites
1. Any working Kubernetes cluster with metrics server installed

The scenario below includes instructions on how to verify that metrics server is running, and if not, how to deploy it.

## Scenario
1. Check if metrics-server is installed

        kubectl get po --all-namespaces | Select-String "metrics-server"

If nothing is returned, you must deploy the metrics server before HPA will work.

    kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.7.2/components.yaml

Run the previous command again to confirm metrics-server is now running.

2. Deploy a sample workload

        kubectl apply -f php-apache.yaml

3. Generate some load on your application.  Open a *new* PowerShell window and run

        .\Generate-Load.ps1

4. It will start generating load on your web server and return the results on the screen.  This should look like a continuous stream of "OK!" messages.

Return to your previous PowerShell window and check how many replicas of your workload are running.

        kubectl get po -n testing

You should see one pod running that represents the load generator script as well as the pods for your php-apache deployment.  You'll observe that even under load, there is only one php-apache pod running.  

5. Let's deploy Horizontal Pod Autoscaler.

        kubectl apply -f hpa.yaml

Wait 20-30 seconds before proceeding to the next step.

6. Confirm how many pods are now running.

        kubectl get po -n testing

You should see multiple php-apache pods running now, up to a maximum of 5.  This is because we set this as the maximum number of replicas in our hpa.yaml manifest.

7. Check the status of the autoscaler

        kubectl get hpa -n testing

This will show you the status and properties of the autoscaler you just created.

8. Let's patch the autoscaler definition in place to increase the max number of replicas to 8

        kubectl patch HorizontalPodAutoscaler demo -n testing -p '{"spec": { "maxReplicas": 8 }}'

9. Confirm how many pods are now running, and check the status of the autoscaler

        kubectl get hpa -n testing
        kubectl get po -n testing

You should see your autoscaler now has a MAXPODS value of 8 and there should be 8 replicas of php-apache running.

10. Stop generating load by returning to the PowerShell window where the load generator is running and pressing Ctl-C.

11. Check again how many pods are running.

        kubectl get po -n testing

You will probably still see 5 pods running.  While HPA will scale a deployment up very quickly, it scales down more slowly.  By default it takes 5 minutes to scale down a deployment.  If you'd like to see your deployment scale back down to 1 replica, wait 5 minutes and run "kubectl get po -n testing" again.

12. When done, roll back your changes.

        kubectl delete -f hpa.yaml
        kubectl delete -f php-apache.yaml

If you deployed the metrics server as part of this scenario you can remove it by typing

    kubectl delete -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.7.2/components.yaml

