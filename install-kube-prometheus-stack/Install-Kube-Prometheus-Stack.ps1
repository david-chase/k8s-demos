Write-Host ""
Write-Host ::: Install-Kube-Prometheus-Stack v1 ::: -ForegroundColor Cyan
Write-Host ""

Write-Host Adding Helm repo... -ForegroundColor Cyan
Write-Host "helm repo add prometheus-community https://prometheus-community.github.io/helm-charts" -ForegroundColor Green
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

Write-Host `nUpdating Helm repos... -ForegroundColor Cyan
Write-Host "helm repo update" -ForegroundColor Green
helm repo update

Write-Host `nInstalling Helm chart... -ForegroundColor Cyan
Write-Host 'helm install prometheus prometheus-community/kube-prometheus-stack `
    -n monitoring `
    --create-namespace `
    -f values.yaml' --ForegroundColor Green
    # --set alertmanager.persistentVolume.storageClass="default" `
    # --set server.persistentVolume.storageClass="default" `
helm install prometheus prometheus-community/kube-prometheus-stack `
    -n monitoring `
    --create-namespace `
    -f values.yaml
 #   --set alertmanager.persistentVolume.storageClass="default" `
 #   --set server.persistentVolume.storageClass="default" `
 #   --set alertmanager.persistentVolume.enabled=false `
 #   --set server.persistentVolume.enabled=false

Write-Host `nAre you installing this on a managed Kubernetes service? [Y/n] -ForegroundColor Cyan
$sInput = Read-Host

if( $sInput.ToLower() -ne "n" ) {
# Disable data collection for system namespaces
    Write-Host `nUpdating Helm deployment... -ForegroundColor Cyan

    Write-Host "helm upgrade prometheus `
    prometheus-community/kube-prometheus-stack `
    --namespace monitoring `
    --set kubeEtcd.enabled=false `
    --set kubeControllerManager.enabled=false `
    --set kubeScheduler.enabled=false" -ForegroundColor Green
    helm upgrade prometheus `
    prometheus-community/kube-prometheus-stack `
    --namespace monitoring `
    --set kubeEtcd.enabled=false `
    --set kubeControllerManager.enabled=false `
    --set kubeScheduler.enabled=false 
} # if( $sInput.ToLower() -ne "n" )