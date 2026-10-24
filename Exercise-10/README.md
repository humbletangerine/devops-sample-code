# Exercise 10: Multi-Node Minikube, Multiple Apps and Replicas

## Aim
Deploy a Product Catalog (2 replicas) and a Shopping Cart (3 replicas) on a three-node local Minikube cluster, with same-application replicas scheduled on different nodes.

## Files
- `product_catalog.py`, `shopping_cart.py`: Flask APIs
- `Dockerfile.product`, `Dockerfile.shopping`: Docker images
- `*_deployment.yaml`: replicas and required pod anti-affinity
- `*_service.yaml`: NodePort services

## Run on Windows PowerShell
Use the script `run-exercise10.ps1` **from this folder** while Docker Desktop is running. The script builds images, creates a separate Minikube profile, loads images into each node, applies manifests, and displays verification output. It does not delete your existing Minikube profile.

Or run the commands in the script individually to capture screenshots as you go.

## Verification evidence to capture
1. `kubectl --context devops-multinode get nodes -o wide` — three Ready nodes.
2. `docker images product-catalog` and `docker images shopping-cart` — two built images.
3. `kubectl --context devops-multinode get deployments` — 2/2 and 3/3 READY.
4. `kubectl --context devops-multinode get pods -o wide` — 5 Pods across 3 nodes.
5. `kubectl --context devops-multinode get services` — both NodePort services.
6. Browser URLs via `minikube -p devops-multinode service product-catalog-service` and `minikube -p devops-multinode service shopping-cart-service` (keep each terminal open for tunnels on Windows Docker driver).

## Demo limitations
Shopping carts are stored in memory independently in each replica. GET after POST might reach another replica; production carts need shared storage, such as Redis or a database. This deployment is a local learning exercise, not a production high-availability system.

## Result
The manifest and application files are prepared for three-node deployment. Record actual successful cluster/Pod/service outputs and browser tests before claiming the deployment has been completed.
