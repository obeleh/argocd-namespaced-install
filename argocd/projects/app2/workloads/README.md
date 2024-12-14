# app2 workloads

Workloads will be deployed in namespace: app2
For every folder in this directory, an ArgoCD Application will be created.
Every folder should contain a `kustomization.yaml` and of course, the resources you want to deploy.

Example:
```yaml
apiVersion: kustomize.config.k8s.io/v1
kind: Kustomization
namespace: argocd-custom-ns
resources:
# - deployment.yaml
```