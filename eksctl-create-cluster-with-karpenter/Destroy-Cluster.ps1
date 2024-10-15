cls
Write-Host ""
Write-Host ::: Destroy EKS Cluster With Karpenter v1 ::: -ForegroundColor Cyan
Write-Host ""

# Read in the config file
$oConfig = Get-Content -Path 'config.ini' | ConvertFrom-StringData

$env:CLUSTER_OWNER = $oConfig.owner
$env:CLUSTER_PURPOSE = $oConfig.purpose 
$env:CLUSTER_CREATEDATE = ( Get-Date -format "yyyy.MM.dd" )

# Start a timer
$oStopWatch = New-Object -TypeName System.Diagnostics.Stopwatch
$oStopWatch.Start()
$env:KARPENTER_NAMESPACE = $oConfig.karpenternamespace
$env:KARPENTER_VERSION = $oConfig.karpenterversion
$env:K8S_VERSION = $oConfig.version

$env:AWS_PARTITION = "aws" # if you are not using standard partitions, you may need to configure to aws-cn / aws-us-gov
$env:CLUSTER_NAME = $oConfig.clustername

Write-Host Deleting CF stacks -ForegroundColor Cyan
Write-Host 'aws cloudformation delete-stack --stack-name "Karpenter-'$env:CLUSTER_NAME'"' -ForegroundColor Green
Write-Host 'aws cloudformation delete-stack --stack-name ( "eksctl-"'$env:CLUSTER_NAME'"-addon-vpc-cni" )' -ForegroundColor Green
Write-Host 'aws cloudformation delete-stack --stack-name ( "eksctl-"'$env:CLUSTER_NAME'"-cluster" )' -ForegroundColor Green
aws cloudformation delete-stack --stack-name "Karpenter-$env:CLUSTER_NAME"
aws cloudformation delete-stack --stack-name ( "eksctl-" + $env:CLUSTER_NAME + "-addon-vpc-cni" )
aws cloudformation delete-stack --stack-name ( "eksctl-" + $env:CLUSTER_NAME + "-cluster" )

Write-Host `nDeleting cluster -ForegroundColor Cyan
Write-Host "eksctl delete cluster --name $env:CLUSTER_NAME" -ForegroundColor Green
eksctl delete cluster --name $env:CLUSTER_NAME

Write-Host `nPausing for 5 minutes to allow the cluster to deprovision -ForegroundColor Cyan
Start-Sleep -Seconds 250

Write-Host `nDeleting IAM role -ForegroundColor Cyan
Write-Host "aws iam delete-role --role-name KarpenterNodeRole-$env:CLUSTER_NAME" -ForegroundColor Green
aws iam delete-role --role-name ( "KarpenterNodeRole-" + $env:CLUSTER_NAME )

# This can take a long time, so make a sound so the user know it's complete
[console]::beep(500,300)

# Stop the timer
$oStopWatch.Stop()
Write-Host `nMinutes elapsed: $oStopWatch.Elapsed.Minutes -ForegroundColor Cyan