Write-Host ""
Write-Host ::: Add Nodegroup to EKS Cluster v1 ::: -ForegroundColor Cyan
Write-Host ""

# Read in the config file
$oConfig = Get-Content -Path 'config.ini' | ConvertFrom-StringData

$sTags = '"Owner=' + $oConfig.owner + ",Purpose=" + $oConfig.purpose + ",CreateDate=" + ( Get-Date -format "yyyy.MM.dd" ) + '"'

$sParams = "create nodegroup --cluster " + $oConfig.clustername + `
    " --name " + $oConfig.ngname + " --nodes " + $oConfig.minsize + `
    " --nodes-min " + $oConfig.minsize + " --nodes-max " + $oConfig.maxsize + `
    " --node-labels " + $sTags + " --instance-types " + $oConfig.instancetype + `
    " --managed --asg-access"
if( $oConfig.spot.ToLower() = "yes" ) { $sParams += " --spot" }

# Show the user the command we're about to execute and let them choose to proceed
Write-Host "eksctl" $sParams`n -ForegroundColor Green
$sResponse = Read-Host -Prompt "Proceed? [Y/n]"
if( $sResponse.ToLower() -eq "n" ) { exit }

# Start a timer
$oStopWatch = New-Object -TypeName System.Diagnostics.Stopwatch
$oStopWatch.Start()

Start-Process "eksctl" -ArgumentList $sParams -Wait -NoNewWindow

# Setup Cluster Autoscaler
Write-Host `nDeploying cluster autoscaler  -ForegroundColor Cyan
$env:CLUSTER_NAME = $oConfig.clustername
envsubst -i .\cluster-autoscaler-autodiscover.template -o cluster-autoscaler-autodiscover.yaml
kubectl apply -f cluster-autoscaler-autodiscover.yaml

# Stop the timer
$oStopWatch.Stop()
Write-Host `nMinutes elapsed: $oStopWatch.Elapsed.Minutes -ForegroundColor Cyan

# This can take a long time, so make a sound so the user knows it's complete
[console]::beep(500,300)