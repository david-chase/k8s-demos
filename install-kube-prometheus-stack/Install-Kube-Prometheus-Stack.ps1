Write-Host ""
Write-Host ::: Install-Kube-Prometheus-Ptack v1 ::: -ForegroundColor Cyan
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
    --set alertmanager.persistentVolume.storageClass="default" `
    --set server.persistentVolume.storageClass="default" `
    --create-namespace ' -ForegroundColor Green
helm install prometheus prometheus-community/kube-prometheus-stack `
    -n monitoring `
    --set alertmanager.persistentVolume.storageClass="default" `
    --set server.persistentVolume.storageClass="default" `
    --create-namespace 

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