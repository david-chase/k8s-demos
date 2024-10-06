Write-Host ""
Write-Host ::: Deploy OPA and Gatekeeper v1 ::: -ForegroundColor Cyan
Write-Host ""

# Show the user the command we're about to execute and let them choose to proceed
Write-Host '
helm repo add gatekeeper https://open-policy-agent.github.io/gatekeeper/charts
helm repo update

helm install gatekeeper/gatekeeper `
  --name-template gatekeeper `
  --namespace gatekeeper-system `
  --create-namespace

kubectl apply -f constraint-template.yaml
kubectl apply -f constraint.yaml'`
-ForegroundColor Green

$sResponse = Read-Host -Prompt "Proceed? [Y/n]"
if( $sResponse.ToLower() -eq "n" ) { exit }

helm repo add gatekeeper https://open-policy-agent.github.io/gatekeeper/charts
helm repo update

helm install gatekeeper/gatekeeper `
  --name-template gatekeeper `
  --namespace gatekeeper-system `
  --create-namespace

kubectl apply -f constraint-template.yaml
kubectl apply -f constraint.yaml