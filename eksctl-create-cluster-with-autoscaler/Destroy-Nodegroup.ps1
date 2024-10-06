Write-Host ""
Write-Host ::: Remove Nodegroup from EKS Cluster v1 ::: -ForegroundColor Cyan
Write-Host ""

# Read in the config file
$oConfig = Get-Content -Path 'config.ini' | ConvertFrom-StringData

$sParams = "delete nodegroup --cluster " + $oConfig.clustername + `
    " --region " + $oConfig.region + `
    " --name " + $oConfig.ngname + `
    " --wait --disable-eviction"

# Show the user the command we're about to execute and let them choose to proceed
Write-Host "eksctl" $sParams`n -ForegroundColor Green
$sResponse = Read-Host -Prompt "Proceed? [Y/n]"
if( $sResponse.ToLower() -eq "n" ) { exit }

# Start a timer
$oStopWatch = New-Object -TypeName System.Diagnostics.Stopwatch
$oStopWatch.Start()

Start-Process "eksctl" -ArgumentList $sParams -Wait -NoNewWindow
Write-Host

# Stop the timer
$oStopWatch.Stop()
Write-Host `nMinutes elapsed: $oStopWatch.Elapsed.Minutes -ForegroundColor Cyan

# This can take a long time, so make a sound so the user know it's complete
[console]::beep(500,300)