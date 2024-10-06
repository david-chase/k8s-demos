Write-Host ""
Write-Host ::: Delete AKS Cluster v1 ::: -ForegroundColor Cyan
Write-Host ""

# Read in the config file
$oConfig = Get-Content -Path 'config.ini' | ConvertFrom-StringData

$sParams1 = "aks delete --resource-group " + $oConfig.rgname + `
    " --name " + $oConfig.clustername + " --yes"
$sParams2 = "group delete --name " + $oConfig.rgname + " --yes"

# Show the user the command we're about to execute and let them choose to proceed
Write-Host "az" $sParams1 -ForegroundColor Green
Write-Host "az" $sParams2`n -ForegroundColor Green
$sResponse = Read-Host -Prompt "Proceed? [Y/n]"
if( $sResponse.ToLower() -eq "n" ) { exit }

# Start a timer
$oStopWatch = New-Object -TypeName System.Diagnostics.Stopwatch
$oStopWatch.Start()

Start-Process "az" -ArgumentList $sParams1 -Wait -NoNewWindow
Start-Process "az" -ArgumentList $sParams2 -Wait -NoNewWindow
kubectl config delete-context $oConfig.clustername
kubectl config delete-cluster $oConfig.clustername

Write-Host

# Stop the timer
$oStopWatch.Stop()
Write-Host `nMinutes elapsed: $oStopWatch.Elapsed.Minutes -ForegroundColor Cyan

# This can take a long time, so make a sound so the user know it's complete
[console]::beep(500,300)