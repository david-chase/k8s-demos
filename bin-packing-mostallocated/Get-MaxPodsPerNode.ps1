param (
   [string]$node="",
   [string]$n=""
)

Write-Host ""
Write-Host ::: Get-MaxPodsPerNode v1 ::: -ForegroundColor Cyan
Write-Host ""

if( $n -ne "" ) { $node = $n }
if( $node -eq "" ) {
    Write-Host Running "kubectl get nodes" -ForegroundColor Cyan
    kubectl get nodes
    Write-Host `nPlease enter a node name: -ForegroundColor Green 
    $node = Read-Host
} # if( $node -eq "" )

kubectl get node $node -ojsonpath='{.status.capacity.pods}'

Write-Host "`n"