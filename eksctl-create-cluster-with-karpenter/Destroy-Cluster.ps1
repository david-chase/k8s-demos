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

Write-Host Deleting CloudFormation templates -ForegroundColor Cyan
$sParams1 = "cloudformation delete-stack --stack-name eksctl-" + $oConfig.clustername + "-addon-vpc-cni"
Write-Host $sParams1 -ForegroundColor Green
$sParams2 = "cloudformation delete-stack --stack-name eksctl-" + $oConfig.clustername + "-cluster"
Write-Host $sParams2 -ForegroundColor Green
$sParams3 = "cloudformation delete-stack --stack-name eksctl-" + $oConfig.clustername + "-nodegroup-" + $oConfig.ngname
Write-Host $sParams3 -ForegroundColor Green
$sParams4 = "cloudformation delete-stack --stack-name Karpenter-" + $oConfig.clustername #  + " --deletion-mode FORCE_DELETE_STACK"
Write-Host $sParams4 -ForegroundColor Green

Start-Process "aws" -ArgumentList $sParams1 -Wait -NoNewWindow
Start-Process "aws" -ArgumentList $sParams2 -Wait -NoNewWindow
Start-Process "aws" -ArgumentList $sParams3 -Wait -NoNewWindow
Start-Process "aws" -ArgumentList $sParams4 -Wait -NoNewWindow

Write-Host `nDeleting cluster -ForegroundColor Cyan
Write-Host "eksctl delete cluster --name $env:CLUSTER_NAME" -ForegroundColor Green
eksctl delete cluster --name $env:CLUSTER_NAME

Write-Host "`nPausing for 10 minutes to allow the cluster to deprovision" -ForegroundColor Cyan
Start-Sleep -Seconds 500

Write-Host "Forcing deletion of any CloudFormation templates in case they failed" -ForegroundColor Cyan
$sParams1 = "cloudformation delete-stack --stack-name eksctl-" + $oConfig.clustername + "-addon-vpc-cni --deletion-mode FORCE_DELETE_STACK"
Write-Host $sParams1 -ForegroundColor Green
$sParams2 = "cloudformation delete-stack --stack-name eksctl-" + $oConfig.clustername + "-cluster --deletion-mode FORCE_DELETE_STACK"
Write-Host $sParams2 -ForegroundColor Green
$sParams3 = "cloudformation delete-stack --stack-name eksctl-" + $oConfig.clustername + "-nodegroup-" + $oConfig.ngname + " --deletion-mode FORCE_DELETE_STACK"
Write-Host $sParams3 -ForegroundColor Green
$sParams4 = "cloudformation delete-stack --stack-name Karpenter-" + $oConfig.clustername + " --deletion-mode FORCE_DELETE_STACK"
Write-Host $sParams4 -ForegroundColor Green

Start-Process "aws" -ArgumentList $sParams1 -Wait -NoNewWindow
Start-Process "aws" -ArgumentList $sParams2 -Wait -NoNewWindow
Start-Process "aws" -ArgumentList $sParams3 -Wait -NoNewWindow
Start-Process "aws" -ArgumentList $sParams4 -Wait -NoNewWindow

Write-Host `nDeleting IAM role -ForegroundColor Cyan

$sRoleName = "KarpenterNodeRole-" + $env:CLUSTER_NAME
$aInstanceProfiles = aws iam list-instance-profiles-for-role --role-name $sRoleName --output json | ConvertFrom-json

for( $i = 0; $i -lt $aInstanceProfiles.Count; $i++ ) {
    Write-Host "aws iam remove-role-from-instance-profile --instance-profile-name " + $aInstanceProfiles.InstanceProfiles[ $i ].InstanceProfileName + " --role-name $sRoleName" -ForegroundColor Green
    aws iam remove-role-from-instance-profile --instance-profile-name $aInstanceProfiles.InstanceProfiles[ $i ].InstanceProfileName --role-name $sRoleName
}

Write-Host "aws iam delete-role --role-name KarpenterNodeRole-$env:CLUSTER_NAME" -ForegroundColor Green
aws iam delete-role --role-name ( "KarpenterNodeRole-" + $env:CLUSTER_NAME )

# This can take a long time, so make a sound so the user know it's complete
[console]::beep(500,300)

# Stop the timer
$oStopWatch.Stop()
Write-Host `nMinutes elapsed: $oStopWatch.Elapsed.Minutes -ForegroundColor Cyan