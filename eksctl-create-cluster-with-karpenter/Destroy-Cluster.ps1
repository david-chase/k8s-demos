cls
Write-Host ""
Write-Host ::: Destroy EKS Cluster With Karpenter v1 ::: -ForegroundColor Cyan
Write-Host ""

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