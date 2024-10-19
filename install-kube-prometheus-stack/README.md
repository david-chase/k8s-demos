# Install kube-prometheus-stack

## Introduction
This simple scenario explains how to install [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/blob/main/charts/kube-prometheus-stack/README.md). 
Kube-prometheus-stack is a simple Helm chart that includes Prometheus, Grafana, kube-state-metrics, node exporter, and several bundled Grafana dashboards.

## Prerequisites
1. Any working Kubernetes cluster
2. Helm installed.

## Scenario

### Script
In you simply want to instakk kube-prometheus-stack quickly, run

    Install-Kube-Prometheus-Stack.ps1

It will take care of everything for you.  If you want to walk through the steps manually, continue reading.

### Step-by-Step
1. Add the Helm repo

        helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

2. Update Helm repos

        helm repo update

3. Install the Helm chart

        helm install prometheus prometheus-community/kube-prometheus-stack `
        -n monitoring `
        --set alertmanager.persistentVolume.storageClass="default" `
        --set server.persistentVolume.storageClass="default" `
        --create-namespace 

4. Disable data collection for control plane namespaces (Optional)

If you're using a managed Kubernetes service like EKS, AKS, or GKE, you will not be able to collect metrics for the namespaces used in the control plane.  You can disable metrics collection for these namespace with the following command.  This is an optional step.

    helm upgrade prometheus `
    prometheus-community/kube-prometheus-stack `
    --namespace monitoring `
    --set kubeEtcd.enabled=false `
    --set kubeControllerManager.enabled=false `
    --set kubeScheduler.enabled=false 