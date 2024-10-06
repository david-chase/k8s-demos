Write-Host ""
Write-Host ::: Delete GKE Cluster v1 ::: -ForegroundColor Cyan
Write-Host ""

# Read in the config file
$oConfig = Get-Content -Path 'config.ini' | ConvertFrom-StringData
$sGcloud = '"' + ( Get-Command gcloud ).Source + '"'

$sParams = $sGcloud + " container clusters delete " + $oConfig.clustername + `
    " --location " + $oConfig.region

# Show the user the command we're about to execute and let them choose to proceed
Write-Host $sParams -ForegroundColor Green
$sResponse = Read-Host -Prompt "Proceed? [Y/n]"
if( $sResponse.ToLower() -eq "n" ) { exit }

# Start a timer
$oStopWatch = New-Object -TypeName System.Diagnostics.Stopwatch
$oStopWatch.Start()

Start-Process pwsh -ArgumentList $sParams -Wait -NoNewWindow

# Stop the timer
$oStopWatch.Stop()
Write-Host `nMinutes elapsed: $oStopWatch.Elapsed.Minutes -ForegroundColor Cyan

# This can take a long time, so make a sound so the user know it's complete
[console]::beep(500,300)