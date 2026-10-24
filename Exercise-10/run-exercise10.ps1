$ErrorActionPreference = 'Stop'
$profile = 'devops-multinode'
Write-Host 'Building images with Docker Desktop...'
docker build -t product-catalog:latest -f Dockerfile.product .
if ($LASTEXITCODE -ne 0) { throw 'Product Catalog image build failed' }
docker build -t shopping-cart:latest -f Dockerfile.shopping .
if ($LASTEXITCODE -ne 0) { throw 'Shopping Cart image build failed' }
Write-Host 'Stopping the existing single-node profile to free memory (NOT deleting it)...'
minikube stop -p minikube
Write-Host 'Starting a SEPARATE three-node Minikube cluster (existing profile is preserved)...'
minikube start -p $profile --driver=docker --nodes=3 --memory=1800 --cpus=2
if ($LASTEXITCODE -ne 0) { throw 'Minikube multi-node start failed: check available RAM and Docker Desktop' }
Write-Host 'Loading image into each node (imagePullPolicy Never requires per-node images)...'
minikube -p $profile image load product-catalog:latest --daemon
if ($LASTEXITCODE -ne 0) { throw 'Product image load failed' }
minikube -p $profile image load shopping-cart:latest --daemon
if ($LASTEXITCODE -ne 0) { throw 'Shopping image load failed' }
Write-Host 'Deploying apps and services...'
foreach ($file in @('product_catalog_deployment.yaml','shopping_cart_deployment.yaml','product_catalog_service.yaml','shopping_cart_service.yaml')) {
  kubectl --context $profile apply -f $file
  if ($LASTEXITCODE -ne 0) { throw "Apply failed for $file" }
}
Write-Host 'Waiting for the deployments...'
kubectl --context $profile rollout status deployment/product-catalog --timeout=180s
kubectl --context $profile rollout status deployment/shopping-cart --timeout=180s
Write-Host '=== NODES ==='
kubectl --context $profile get nodes
Write-Host '=== DEPLOYMENTS ==='
kubectl --context $profile get deployments
Write-Host '=== POD DISTRIBUTION ==='
kubectl --context $profile get pods -o wide
Write-Host '=== SERVICES ==='
kubectl --context $profile get services
Write-Host 'To access a service in separate PowerShell windows:'
Write-Host 'minikube -p devops-multinode service product-catalog-service'
Write-Host 'minikube -p devops-multinode service shopping-cart-service'
