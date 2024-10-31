# Vertical Pod autoscaler

## Introduction
This simple scenario demonstrates how to deploy and use Vertical Pod Autoscaler, and how it scales up a deployment when under load.

## Prerequisites
1. Any working Kubernetes cluster with metrics server running.

The scenario below includes instructions on how to verify that metrics server is running, and if not, how to deploy it.

## Scenario
1. Check if metrics-server is installed

        kubectl get po --all-namespaces | Select-String "metrics-server"

If nothing is returned, you must deploy the metrics server before VPA will work.

    kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.7.2/components.yaml

Run the previous command again to confirm metrics-server is now running.

2. Install Vertical Pod Autoscaler

        helm upgrade --install vertical-pod-autoscaler oci://ghcr.io/stevehipwell/helm-charts/vertical-pod-autoscaler --version 1.7.1 -n kube-system

3. Verify VPA is running

        kubectl get po -n kube-system | Select-String vertical

You should see three pods running:

| Pod | Description |
|---|---|
| vertical-pod-autoscaler-admission-controller | This pod sizes workloads as they're created |
| vertical-pod-autoscaler-recommender | This pod generates sizing recommendations for a workload |
| vertical-pod-autoscaler-updater | This pod updates and restarts pods |

4. Deploy a sample workload

        kubectl apply -f php-apache.yaml

5. Check the resources being used by your deployment

        ./Get-Pod-Resources.ps1 -n testing

You'll see there is a single replica of php-apache running with CPU requests of 50m and Memory requests of 100Mi.

6. Generate some load on your application.  Open a *new* PowerShell window and run

        .\Generate-Load.ps1

7. It will start generating load on your web server and return the results on the screen.  This should look like a continuous stream of "OK!" messages.

8. Deploy Vertical Pod Autoscaler with Update Mode set to "Off"

        kubectl apply -f vpa.yaml

9. Wait about a minute, then we'll check if the VPA recommender is generating sizing recommendations

        kubectl describe vpa php-apache-vpa -n testing

You should see something like this at the end of the output, confirming that sizing recommendations are being generated:

      Recommendation:
        Container Recommendations:  
          Container Name:  php-apache
          Lower Bound:
            Cpu:     178m
            Memory:  262144k
          Target:
            Cpu:     920m
            Memory:  262144k
          Uncapped Target:
            Cpu:     920m
            Memory:  262144k
          Upper Bound:
            Cpu:     2
            Memory:  2000Mi

10. Now check the requests and limits on our pod:

        ./Get-Pod-Resources.ps1 -n testing

Nothing has changed because we still have Update Mode set to "Off".  

11. Apply vpa-auto.yaml.  The only difference with this file is it sets Update Mode to Auto.

        kubectl apply -f vpa-auto.yaml

12. Let's force a restart on our deployment

        kubectl rollout restart deploy/php-apache -n testing

13. Check our pod resource requests and limits again

        ./Get-Pod-Resources.ps1 -n testing

This time you should see CPU and Memory requests have been updated for our php-apache pod.  Our pod has been successfully scaled!

14. When you're done, let's return our cluster to its original state

        kubectl delete -f vpa-auto.yaml
        kubectl delete -f php-apache.yaml
        helm uninstall vertical-pod-autoscaler -n kube-system

This concludes the scenario.
	 
