Start-Process  -filepath "kubectl" -ArgumentList "port-forward svc/prometheus-kube-prometheus-prometheus -n monitoring 9090"
Start-Process "http://localhost:9090"