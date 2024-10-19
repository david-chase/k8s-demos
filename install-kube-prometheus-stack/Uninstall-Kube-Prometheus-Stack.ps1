Write-Host ""
Write-Host ::: Install-Kube-Prometheus-Ptack v1 ::: -ForegroundColor Cyan
Write-Host ""

Write-Host `nUninstalling Helm chart... -ForegroundColor Cyan
Write-Host "helm uninstall prometheus -n monitoring" -ForegroundColor Green
helm uninstall prometheus -n monitoring