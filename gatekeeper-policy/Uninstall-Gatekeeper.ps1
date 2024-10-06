Write-Host ""
Write-Host ::: Uninstall OPA and Gatekeeper v1 ::: -ForegroundColor Cyan
Write-Host ""

# Show the user the command we're about to execute and let them choose to proceed
Write-Host '
kubectl delete -f valid-deploy.yaml
kubectl delete -f constraint.yaml
kubectl delete -f constraint-template.yaml
helm uninstall gatekeeper -n gatekeeper-system'`
-ForegroundColor Green

$sResponse = Read-Host -Prompt "Proceed? [Y/n]"
if( $sResponse.ToLower() -eq "n" ) { exit }

kubectl delete -f valid-deploy.yaml
kubectl delete -f constraint.yaml
kubectl delete -f constraint-template.yaml
helm uninstall gatekeeper -n gatekeeper-system