# Question 9 — Quick-Commerce Monitoring and Incident Diagnosis

This lab deploys a Flask product-availability API as three Kubernetes replicas, exposes it with a Service, scrapes per-pod application metrics with Prometheus, displays request and resource panels in Grafana, and provides a reproducible pod-failure/recovery exercise.

## Files

- `app.py`: Flask availability API (`/availability/<product_id>`), health endpoint and Prometheus `/metrics`.
- `Dockerfile`, `requirements.txt`: container image build.
- `k8s/`: namespaces, 3-replica Deployment, NodePort Service, Prometheus RBAC/config/rules/deployment/service, Grafana datasource/dashboard provisioning/deployment/service.
- `grafana/dashboard.json`: provisioned Quick-Commerce dashboard.
- `load_test.py`: concurrent repeated requests with status counts, throughput and p95 latency.
- `scripts/deploy.ps1`: deploys onto the existing **single-node** Minikube profile named `minikube`; this is intentional and does not recreate the failed three-node profile.
- `scripts/diagnose.ps1`: collects Kubernetes, event, resource and Docker state.

## 1. Deploy

Open PowerShell in this folder and run:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\deploy.ps1
```

The script expects Docker Desktop to be running and uses the existing `minikube` profile. It builds `quick-commerce-api:1.0` into that profile and creates three API Pods. It does not use the old `devops-multinode` profile.

## 2. Open the API

In a separate PowerShell window:

```powershell
kubectl port-forward -n quick-commerce svc/product-api 8081:80
```

Keep that window open. Test from another PowerShell window:

```powershell
Invoke-RestMethod http://127.0.0.1:8081/availability/101
Invoke-RestMethod http://127.0.0.1:8081/products
```

Test an unknown ID (expected HTTP 404):

```powershell
Invoke-WebRequest http://127.0.0.1:8081/availability/999
```

## 3. Generate traffic

From the lab folder:

```powershell
python .\load_test.py --url http://127.0.0.1:8081 --requests 600 --workers 20
```

The `999` test ID intentionally produces HTTP 404; that is an application response, not a connectivity failure. A status count of `0` indicates a connection/timeout failure.

## 4. Grafana and Prometheus

- Grafana: `http://localhost:30300`
- Username: `admin`
- Password: `quickcommerce123`
- Prometheus: `http://localhost:30090`

Grafana provisions a Prometheus data source and a dashboard named **Quick-Commerce API Operations**. Panels include healthy API pod targets, request rate, container CPU, container memory, Flask worker CPU/memory and p95 latency.

Prometheus discovers the app Pods using their `prometheus.io/*` annotations. Container CPU and memory panels use kubelet/cAdvisor metrics via the Kubernetes API proxy. Process-level metrics are also exported directly by Flask for a second view of the worker process.

## 5. Alert threshold and justification

Prometheus rule `ProductAPIReplicaShortfall` fires when fewer than three product API Pod scrape targets are healthy for one minute. The Deployment's intended capacity is three replicas; losing one removes at least one-third of the intended replica capacity and reduces redundancy during a demand spike. A one-minute hold avoids firing on a brief scrape gap.

A second rule, `ProductAPIHighProcessCPU`, fires when a worker's process CPU metric remains above 80% for two minutes. This is an early-warning threshold, not a universal capacity limit; it should be tuned after observing the normal load baseline.

View alert state in Prometheus under **Alerts** at `http://localhost:30090/alerts`.

## 6. Fault simulation and diagnosis

Record the healthy baseline first:

```powershell
kubectl get pods -n quick-commerce -o wide
kubectl get endpoints -n quick-commerce product-api
kubectl top pods -n quick-commerce
```

Delete one API Pod (Deployment should create a replacement):

```powershell
$pod = kubectl get pods -n quick-commerce -l app=product-api -o jsonpath='{.items[0].metadata.name}'
kubectl delete pod $pod -n quick-commerce
kubectl get pods -n quick-commerce -w
```

In another window, repeatedly call `/availability/101`. The Service should route requests to the remaining ready Pods while the Deployment replaces the deleted Pod. The Prometheus replica-shortfall alert may briefly fire if fewer than three targets remain healthy for a full minute.

Diagnosis commands:

```powershell
kubectl get deployment,replicaset,pods,svc,endpoints -n quick-commerce -o wide
kubectl describe deployment product-api -n quick-commerce
kubectl get events -n quick-commerce --sort-by=.lastTimestamp
kubectl logs -n quick-commerce deployment/product-api --tail=80
kubectl top pods -n quick-commerce
```

Interpretation:

- `CrashLoopBackOff`, `ImagePullBackOff`, non-ready Pods, or fewer than three ready replicas indicate a workload/application/runtime problem.
- Three Ready Pods but failed client calls, missing Service endpoints, or a broken port-forward indicate a Service/connectivity path problem.
- High CPU/memory together with increased latency suggests capacity/resource pressure; low resource usage with connection failures suggests checking Service selectors, endpoints and port-forwarding.

## 7. Recovery

```powershell
kubectl rollout status deployment/product-api -n quick-commerce --timeout=180s
kubectl get pods -n quick-commerce -o wide
kubectl get endpoints -n quick-commerce product-api
Invoke-RestMethod http://127.0.0.1:8081/availability/101
```

A recovered state is three Ready Pods, three Service endpoints, successful API responses and healthy Prometheus targets. Capture before/during/after screenshots for the incident diagnosis evidence.

## Evidence checklist

1. API response for `/availability/101`.
2. `kubectl get pods -o wide` showing three replicas.
3. Load generator output with request count, throughput and status codes.
4. Grafana dashboard with request rate, CPU, memory and pod health panels.
5. Prometheus Alerts page showing the configured rule (and firing state during a sufficiently long replica shortfall if it occurs).
6. Pod deletion and replacement output.
7. Recovery output showing three Ready Pods and successful API response.

Do not claim a successful deployment, alert firing, or recovery screenshot until you have actually observed it on your machine.
