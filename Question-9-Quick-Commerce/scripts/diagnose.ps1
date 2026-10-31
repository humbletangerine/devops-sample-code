Write-Host '=== Kubernetes workload state ==='
kubectl get deployment,replicaset,pods,svc,endpoints -n quick-commerce -o wide
Write-Host "`n=== Recent namespace events ==="
kubectl get events -n quick-commerce --sort-by=.lastTimestamp | Select-Object -Last 20
Write-Host "`n=== Pod resource usage (metrics-server required) ==="
kubectl top pods -n quick-commerce
Write-Host "`n=== Docker Minikube container ==="
docker inspect minikube --format 'Container={{.Name}} State={{.State.Status}}' 2>$null
