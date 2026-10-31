$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

Write-Host 'Checking Docker Engine...'
docker info --format '{{.ServerVersion}}' | Out-Host
if ($LASTEXITCODE -ne 0) { throw 'Docker Engine is unavailable. Start Docker Desktop first.' }

Write-Host 'Starting the existing SINGLE-NODE minikube profile (not the failed 3-node profile)...'
$status = minikube status -p minikube 2>&1 | Out-String
if ($LASTEXITCODE -ne 0 -or $status -notmatch 'host: Running') {
    minikube start -p minikube --driver=docker --cpus=4 --memory=3584
    if ($LASTEXITCODE -ne 0) { throw 'Minikube did not start. Stop here and share the error.' }
}

Write-Host 'Building API image inside the existing Minikube profile...'
minikube -p minikube image build -t quick-commerce-api:1.0 -f Dockerfile .
if ($LASTEXITCODE -ne 0) { throw 'API image build failed.' }

kubectl config use-context minikube | Out-Host
kubectl apply -f .\k8s\00-namespaces.yaml
kubectl apply -f .\k8s\10-app-deployment.yaml
kubectl apply -f .\k8s\11-app-service.yaml
kubectl apply -f .\k8s\20-prometheus-rbac.yaml
kubectl apply -f .\k8s\21-prometheus-config.yaml
kubectl apply -f .\k8s\22-prometheus-deployment.yaml
kubectl apply -f .\k8s\23-prometheus-service.yaml
kubectl apply -f .\k8s\30-grafana-config.yaml

Write-Host 'Creating Grafana dashboard ConfigMap...'
kubectl create configmap grafana-dashboard -n monitoring --from-file=quick-commerce.json=.\grafana\dashboard.json --dry-run=client -o yaml | kubectl apply -f -
if ($LASTEXITCODE -ne 0) { throw 'Grafana dashboard ConfigMap creation failed.' }

kubectl apply -f .\k8s\31-grafana-deployment.yaml
kubectl apply -f .\k8s\32-grafana-service.yaml

Write-Host 'Enabling metrics-server for kubectl top pod diagnostics...'
minikube addons enable metrics-server -p minikube

Write-Host 'Waiting for application and monitoring deployments...'
kubectl rollout status deployment/product-api -n quick-commerce --timeout=180s
kubectl rollout status deployment/prometheus -n monitoring --timeout=180s
kubectl rollout status deployment/grafana -n monitoring --timeout=180s

Write-Host ''
Write-Host 'DEPLOYMENT COMPLETE. Check:'
kubectl get pods -n quick-commerce -o wide
kubectl get pods -n monitoring -o wide
kubectl get svc -n quick-commerce
kubectl get svc -n monitoring
Write-Host ''
Write-Host 'Next: open another PowerShell window and run:'
Write-Host 'kubectl port-forward -n quick-commerce svc/product-api 8081:80'
Write-Host 'Grafana: http://localhost:30300 (admin / quickcommerce123)'
Write-Host 'Prometheus: http://localhost:30090'
