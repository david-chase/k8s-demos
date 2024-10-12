param (
    [string]$namespace,
    [string]$n
 )

Write-Host ""
Write-Host ::: Get-Pods-By-Node v1 ::: -ForegroundColor Cyan
Write-Host ""

if( $n -ne "" ) { $namespace = $n }
if( $namespace -eq "" ) {
    Write-Host Running "kubectl get ns" -ForegroundColor Cyan
    kubectl get ns
    Write-Host `nPlease enter a namespace: -ForegroundColor Green 
    $namespace = Read-Host
} # if( $namespace -eq "" )

kube-capacity -n $namespace -p

Write-Host