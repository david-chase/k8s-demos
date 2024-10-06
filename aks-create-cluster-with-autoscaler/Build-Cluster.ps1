Write-Host ""
Write-Host ::: Build AKS Cluster v1 ::: -ForegroundColor Cyan
Write-Host ""

# Read in the config file
$oConfig = Get-Content -Path 'config.ini' | ConvertFrom-StringData

$sTags = '"Owner=' + $oConfig.owner + ",Purpose=" + $oConfig.purpose + ",CreateDate=" + ( Get-Date -format "yyyy.MM.dd" ) + '"'

$sParams1 = "group create --name " + $oConfig.rgname + " --location " + $oConfig.region + " --output table"
$sParams2 = "aks create --resource-group " + $oConfig.rgname + `
    " --name " + $oConfig.clustername + `
    " --node-count " + $oConfig.minsize + `
    " --min-count " + $oConfig.minsize + `
    " --max-count " + $oConfig.maxsize + `
    " --node-resource-group " + $oConfig.nrgname + `
    " --nodepool-name " + $oConfig.ngname + `
    " --nodepool-tags " + $sTags + `
    " --tags " + $sTags + `
    " --tier " + $oConfig.tier + `
    " --node-vm-size " + $oConfig.instancetype + `
    " --kubernetes-version " + $oConfig.version + `
    " --generate-ssh-keys --enable-cluster-autoscaler --output table"

# Show the user the command we're about to execute and let them choose to proceed
Write-Host "az" $sParams1 -ForegroundColor Green
Write-Host "az" $sParams2`n -ForegroundColor Green
$sResponse = Read-Host -Prompt "Proceed? [Y/n]"
if( $sResponse.ToLower() -eq "n" ) { exit }

# Start a timer
$oStopWatch = New-Object -TypeName System.Diagnostics.Stopwatch
$oStopWatch.Start()

Write-Host `nCreating resource group -ForegroundColor Cyan
Start-Process "az" -ArgumentList $sParams1 -Wait -NoNewWindow
Write-Host `nCreating cluster -ForegroundColor Cyan
Start-Process "az" -ArgumentList $sParams2 -Wait -NoNewWindow
Write-Host `nUpdating kube config -ForegroundColor Cyan
az aks get-credentials --resource-group $oConfig.rgname --name $oConfig.clustername

Write-Host

# Stop the timer
$oStopWatch.Stop()
Write-Host `nMinutes elapsed: $oStopWatch.Elapsed.Minutes -ForegroundColor Cyan

# This can take a long time, so make a sound so the user know it's complete
[console]::beep(500,300)