# ArgoCD namespaced installation with KCL

This is a declarative way to install ArgoCD in a namespace using Kustomize
ArgoCD is configured to be "self-managed" so updating ArgoCD can be done by updating your git repo.
The kustomize configuration is generated using KCL-lang
RBAC permissions are included so that ArgoCD can manage resources in multiple namespaces
ArgoCD resources are only read from the namespace where ArgoCD is installed

I created this project because I wanted a fully declarative way use a namespaced installation of ArgoCD.
Other options I found were either running `argocd cluster add` or using a Token that would have been pre-created.

## Prerequisites

- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [kcl-lang](https://www.kcl-lang.io/docs/user_docs/getting-started/install#1-install-kcl)
- make: for triggering the kcl build
- a Kubernetes cluster

## Rendering for your own repo

- Modify values.yaml in the kcl directory to point to your own repo
- Either remove the argocd folder or modify the values.yaml to point to a different output directory
- Run `make render` in the kcl directory
- Copy over the argocd folder to your repo

## Test steps with Minikube

```bash
minikube start
cd kcl 
make render # it's using values.yaml but in this repo everything is already rendered and committed
cd argocd/bootstrap
kcl apply -k .
```
