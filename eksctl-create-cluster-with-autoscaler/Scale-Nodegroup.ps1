param (
    [string]$nodes,
    [string]$n
 )

Write-Host ""
Write-Host ::: Scale Nodegroup in EKS Cluster v1 ::: -ForegroundColor Cyan
Write-Host ""

if( $n -ne "" ) { $nodes = $n }
if( -not $nodes ) { Write-Host "Syntax: Scale-Nodegroup.ps1 -nodes <numnodes>"; exit }

# Read in the config file
$oConfig = Get-Content -Path 'config.ini' | ConvertFrom-StringData

$sParams = "scale nodegroup --cluster " + $oConfig.clustername + ` 
    " --nodes " + $nodes + `
    " --name " + $oConfig.ngname + `
    " --nodes-min " + $nodes + `
    " --nodes-max " + $oConfig.maxsize + `
    " --wait"

# Show the user the command we're about to execute and let them choose to proceed
Write-Host "eksctl" $sParams`n -ForegroundColor Green
$sResponse = Read-Host -Prompt "Proceed? [Y/n]"
if( $sResponse.ToLower() -eq "n" ) { exit }

Start-Process "eksctl" -ArgumentList $sParams -Wait -NoNewWindow