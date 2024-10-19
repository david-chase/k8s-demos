Start-Process "http://localhost:3001"
# Start-Process  -filepath "kubectl" -ArgumentList "kubectl port-forward --namespace monitoring svc/prometheus-grafana 3001:80"
kubectl port-forward --namespace monitoring svc/prometheus-grafana 3001:80