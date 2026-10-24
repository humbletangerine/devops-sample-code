# Exercise 10 - Execution and Troubleshooting

## Objective
Deploy Product Catalog and Shopping Cart Flask applications on a
three-node Minikube Kubernetes cluster.

## Implementation
- Product Catalog: 2 replicas
- Shopping Cart: 3 replicas
- Dockerfiles and Kubernetes manifests prepared
- Three-node Minikube deployment attempted

## Execution Result
The three-node cluster could not be successfully initialized.

Docker Desktop encountered repeated backend failures while creating
the third Kubernetes node.

Observed errors:
- Docker Desktop unable to start
- containerd SIGBUS / bus error
- Missing devops-multinode-m03 container

## Troubleshooting
- Restarted WSL and Docker Desktop
- Verified Docker Engine was operational
- Removed the incomplete devops-multinode cluster
- Verified original Minikube profile remained intact

## Final Status
Source code and Kubernetes configuration prepared.
Multi-node deployment and replica verification remain incomplete.
