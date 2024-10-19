cls
Write-Host ""
Write-Host ::: Build EKS Cluster With Karpenter v1 ::: -ForegroundColor Cyan
Write-Host ""

# Read in the config file
$oConfig = Get-Content -Path 'config.ini' | ConvertFrom-StringData

$env:CLUSTER_OWNER = $oConfig.owner
$env:CLUSTER_PURPOSE = $oConfig.purpose 
$env:CLUSTER_CREATEDATE = ( Get-Date -format "yyyy.MM.dd" )

# Start a timer
$oStopWatch = New-Object -TypeName System.Diagnostics.Stopwatch
$oStopWatch.Start()

Write-Host `nReading AWS settings -ForegroundColor Cyan
$env:KARPENTER_NAMESPACE = $oConfig.karpenternamespace
$env:KARPENTER_VERSION = $oConfig.karpenterversion
$env:K8S_VERSION = $oConfig.version

$env:AWS_PARTITION = "aws" # if you are not using standard partitions, you may need to configure to aws-cn / aws-us-gov
$env:CLUSTER_NAME = $oConfig.clustername
$env:AWS_DEFAULT_REGION = $oConfig.region
$env:AWS_ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
$env:TEMPOUT = "NUL"
$env:ARM_AMI_ID = "$(aws ssm get-parameter --name /aws/service/eks/optimized-ami/$env:K8S_VERSION/amazon-linux-2-arm64/recommended/image_id --query Parameter.Value --output text)"
$env:AMD_AMI_ID = "$(aws ssm get-parameter --name /aws/service/eks/optimized-ami/$env:K8S_VERSION/amazon-linux-2/recommended/image_id --query Parameter.Value --output text)"
$env:GPU_AMI_ID = "$(aws ssm get-parameter --name /aws/service/eks/optimized-ami/$env:K8S_VERSION/amazon-linux-2-gpu/recommended/image_id --query Parameter.Value --output text)"

# Deploy the Karpenter CloudFormation stackset
Write-Host "`nDeploy the Karpenter CloudFormation stackset `n" -ForegroundColor Cyan
Write-Host 'curl -fsSL https://raw.githubusercontent.com/aws/karpenter-provider-aws/v'$env:KARPENTER_VERSION'/website/content/en/preview/getting-started/getting-started-with-karpenter/cloudformation.yaml' -ForegroundColor Green
curl -fsSL https://raw.githubusercontent.com/aws/karpenter-provider-aws/v"$env:KARPENTER_VERSION"/website/content/en/preview/getting-started/getting-started-with-karpenter/cloudformation.yaml `
  > "./karpenter.cftemplate"
Write-Host 'aws cloudformation deploy `
  --stack-name "Karpenter-'$env:CLUSTER_NAME'" `
  --template-file "./karpenter.cftemplate" `
  --capabilities CAPABILITY_NAMED_IAM `
  --parameter-overrides "ClusterName=$env:CLUSTER_NAME"' -ForegroundColor Green
aws cloudformation deploy `
  --stack-name "Karpenter-$env:CLUSTER_NAME" `
  --template-file "./karpenter.cftemplate" `
  --capabilities CAPABILITY_NAMED_IAM `
  --parameter-overrides "ClusterName=$env:CLUSTER_NAME" 

# Build the cluster
Write-Host "`nCreating cluster $env:CLUSTER_NAME `n" -ForegroundColor Cyan
Write-Host "envsubst -i .\cluster.template -o cluster.config" -ForegroundColor Green
envsubst -i .\cluster.template -o cluster.config 
Write-Host "eksctl create cluster -f cluster.config" -ForegroundColor Green
eksctl create cluster -f cluster.config

Write-Host "`nExporting kubeconfig" -ForegroundColor Cyan
Write-Host "aws eks update-kubeconfig --region $env:AWS_DEFAULT_REGION --name $env:CLUSTER_NAME" -ForegroundColor Green
aws eks update-kubeconfig --region $env:AWS_DEFAULT_REGION --name $env:CLUSTER_NAME


$env:CLUSTER_ENDPOINT="$(aws eks describe-cluster --name "$env:CLUSTER_NAME" --query "cluster.endpoint" --output text)"
$env:KARPENTER_IAM_ROLE_ARN="arn:$env:AWS_PARTITION:iam::$env:AWS_ACCOUNT_ID:role/$env:CLUSTER_NAME-karpenter"

Write-Host `nCreating a linked role to allow using spot instances  `n -ForegroundColor Cyan
Write-Host `nNOTE: If you see an error '"Service role name AWSServiceRoleForEC2Spot has been taken in this account"' simply disregard.  It means the linked role is already created.
Write-Host "aws iam create-service-linked-role --aws-service-name spot.amazonaws.com" -ForegroundColor Green
aws iam create-service-linked-role --aws-service-name spot.amazonaws.com

Write-Host `nInstalling Karpenter  -ForegroundColor Cyan
Write-Host "helm registry logout public.ecr.aws" -ForegroundColor Green
Write-Host 'helm upgrade --install karpenter oci://public.ecr.aws/karpenter/karpenter --version "$env:KARPENTER_VERSION" `
  --namespace "'$env:KARPENTER_NAMESPACE'" --create-namespace `
  --set "settings.clusterName='$env:CLUSTER_NAME'" `
  --set "settings.interruptionQueue='$env:CLUSTER_NAME'" `
  --set controller.resources.requests.cpu=1 `
  --set controller.resources.requests.memory=1Gi `
  --set controller.resources.limits.cpu=1 `
  --set controller.resources.limits.memory=1Gi `
  --wait' -ForegroundColor Green
helm registry logout public.ecr.aws
helm upgrade --install karpenter oci://public.ecr.aws/karpenter/karpenter --version "$env:KARPENTER_VERSION" --namespace "$env:KARPENTER_NAMESPACE" --create-namespace `
  --set "settings.clusterName=$env:CLUSTER_NAME" `
  --set "settings.interruptionQueue=$env:CLUSTER_NAME" `
  --set controller.resources.requests.cpu=1 `
  --set controller.resources.requests.memory=1Gi `
  --set controller.resources.limits.cpu=1 `
  --set controller.resources.limits.memory=1Gi `
  --wait

Write-Host `nCreating nodepool  -ForegroundColor Cyan
Write-Host "envsubst -i .\nodepool.template -o nodepool.yaml" -ForegroundColor Green
envsubst -i .\nodepool.template -o nodepool.yaml
Write-Host "kubectl apply -f nodepool.yaml" -ForegroundColor Green
kubectl apply -f nodepool.yaml

# Stop the timer
$oStopWatch.Stop()
Write-Host `nMinutes elapsed: $oStopWatch.Elapsed.Minutes -ForegroundColor Cyan

# This can take a long time, so make a sound so the user know it's complete
[console]::beep(500,300)
