Write-Host ""
Write-Host ::: Build GKE Cluster v1 ::: -ForegroundColor Cyan
Write-Host ""

# Read in the config file
$oConfig = Get-Content -Path 'config.ini' | ConvertFrom-StringData

$sTags = '"owner=' + $oConfig.owner + ",purpose=" + $oConfig.purpose + ",createdate=" + ( Get-Date -format "yyyy-MM-dd" ) + '"'
$sGcloud = '"' + ( Get-Command gcloud ).Source + '"'

# gcloud container clusters create k8s-tracker --cluster-version 1.27  --machine-type n1-standard-2 --num-nodes 1 --zone asia-southeast2-a

$sParams1 = $sGcloud + " services enable container.googleapis.com"
$sParams2 = $sGcloud + " container clusters create " + $oConfig.clustername + `
    " --zone=" + $oConfig.region + `
    " --enable-autoscaling" + `
    " --num-nodes=" + $oConfig.minsize + `
    " --min-nodes=" + $oConfig.minsize + `
    " --max-nodes=" + $oConfig.maxsize + `
    " --labels=" + $sTags + `
    " --cluster-version=" + $oConfig.version
if( $oConfig.spot.ToLower() = "yes" ) { $sParams2 += " --spot" }

# Show the user the command we're about to execute and let them choose to proceed
Write-Host $sParams1 -ForegroundColor Green
Write-Host $sParams2`n -ForegroundColor Green
$sResponse = Read-Host -Prompt "Proceed? [Y/n]"
if( $sResponse.ToLower() -eq "n" ) { exit }

# Start a timer
$oStopWatch = New-Object -TypeName System.Diagnostics.Stopwatch
$oStopWatch.Start()

Start-Process pwsh -ArgumentList $sParams1 -Wait -NoNewWindow
Start-Process pwsh -ArgumentList $sParams2 -Wait -NoNewWindow

# Stop the timer
$oStopWatch.Stop()
Write-Host `nMinutes elapsed: $oStopWatch.Elapsed.Minutes -ForegroundColor Cyan

# This can take a long time, so make a sound so the user know it's complete
[console]::beep(500,300)