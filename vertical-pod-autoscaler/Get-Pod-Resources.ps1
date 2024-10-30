param (
   [string]$namespace="",
   [string]$n=""
)

Write-Host ""
Write-Host ::: Get-Pod-Resources v1 ::: -ForegroundColor Cyan
Write-Host ""

if( $n -ne "" ) { $namespace = $n }
if( $namespace -eq "" ) { $namespace = "all" }

if( $namespace.ToLower() -ne "all" ) {
    kubectl get pods -n $namespace -o custom-columns="POD:metadata.name,CPU_REQ:spec.containers[*].resources.requests.cpu,MEM_REQ:spec.containers[*].resources.requests.memory,CPU_LIM:spec.containers[*].resources.limits.cpu,MEM_LIM:spec.containers[*].resources.limits.memory"
} else
{
    kubectl get pods --all-namespaces -o custom-columns="POD:metadata.name,CPU_REQ:spec.containers[*].resources.requests.cpu,MEM_REQ:spec.containers[*].resources.requests.memory,CPU_LIM:spec.containers[*].resources.limits.cpu,MEM_LIM:spec.containers[*].resources.limits.memory"
} # if( $namespace.ToLower() <> "all" )