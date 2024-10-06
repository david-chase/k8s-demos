Write-Host ""
Write-Host ::: EKS Set Context v1 ::: -ForegroundColor Cyan
Write-Host ""

# Read in the config file
$oConfig = Get-Content -Path 'config.ini' | ConvertFrom-StringData

$sParams = "eks update-kubeconfig --region " + $oConfig.region + " --name " + $oConfig.clustername

Write-Host "aws" $sParams`n -ForegroundColor Green
Start-Process "aws" -ArgumentList $sParams -Wait -NoNewWindow