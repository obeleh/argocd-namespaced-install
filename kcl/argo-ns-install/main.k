import yaml
import file
import application_prerequisites

_output_folder = option("output_folder", default="output")
_argo_namespace = option("argo_namespace", required=True)
_argo_version = option("argo_version", required=True)
_application_namespaces = option("application_namespaces", type="list", required=True)
_generate_crd_kustomization = option("generate_crd_kustomization", type="bool", default=False)
_self_manage_config = option("self_manage_config", type="dict", default=False)

_self_manage_config_defaults = {
    path = "argocd/gitopscontroller"
    targetRevision = "main"
    # repoURL = "<your-repo-url>"
}

if not file.exists("${_output_folder}"):
    file.mkdir("${_output_folder}")

if not file.exists("${_output_folder}/gitopscontroller"):
    file.mkdir("${_output_folder}/gitopscontroller")

if _generate_crd_kustomization and not file.exists("${_output_folder}/crds"):
    file.mkdir("${_output_folder}/crds")

_crd_kustomization = {
    apiVersion = "kustomize.config.k8s.io/v1beta1"
    kind = "Kustomization"
    resources = [
        "https://raw.githubusercontent.com/argoproj/argo-cd/${_argo_version}/manifests/crds/application-crd.yaml"
        "https://raw.githubusercontent.com/argoproj/argo-cd/${_argo_version}/manifests/crds/appproject-crd.yaml"
        "https://raw.githubusercontent.com/argoproj/argo-cd/${_argo_version}/manifests/crds/applicationset-crd.yaml"
    ]
}

_in_cluster = {
    apiVersion = "v1"
    kind = "Secret"
    metadata = {
        name = "in-cluster"
        namespace = _argo_namespace
        labels = {
            "argocd.argoproj.io/secret-type" = "cluster"
        }
    }
    stringData = {
        config = r"""{"tlsClientConfig":{"insecure":false}}"""
        name = "in-cluster"
        namespaces = ",".join(_application_namespaces)
        server = "https://kubernetes.default.svc"
    }
}

_argocd_custom_ns = {
    apiVersion = "v1"
    kind = "Namespace"
    metadata = {
        name = _argo_namespace
    }
}

_kustomization = {
    apiVersion = "kustomize.config.k8s.io/v1beta1"
    kind = "Kustomization"
    namespace = _argo_namespace
    resources = [
        "https://raw.githubusercontent.com/argoproj/argo-cd/${_argo_version}/manifests/namespace-install.yaml"
    ] + ["${ns}-prerequisites.yaml" for ns in _application_namespaces]
}

if _self_manage_config:
    _gitops_controller_app = {
        apiVersion = "argoproj.io/v1alpha1"
        kind = "Application"
        metadata = {
            name = "gitops-controller"
            namespace = _argo_namespace
            finalizers = [
                "resources-finalizer.argocd.argoproj.io"
            ]
        }
        spec = {
            destination = {
                namespace = _argo_namespace
                server = "https://kubernetes.default.svc"
            }
            project = "gitops-controller"
            source = {
                **_self_manage_config_defaults
                **_self_manage_config
            }
        }
    }

_gitops_controller_prerequisites = _application_ns_resources("gitops-controller", _argo_namespace, _argo_namespace)

_ = [yaml.dump_all_to_file(_application_ns_resources(ns, _argo_namespace, ns), "${_output_folder}/gitopscontroller/${ns}-prerequisites.yaml") for ns in _application_namespaces]

if _self_manage_config:
    yaml.dump_all_to_file(_gitops_controller_prerequisites, "${_output_folder}/gitopscontroller/gitops-controller-prerequisites.yaml")
    yaml.dump_to_file(_gitops_controller_app, "${_output_folder}/gitopscontroller/application.yaml")
    _kustomization["resources"] = ["gitops-controller-prerequisites.yaml"] + _kustomization["resources"] + ["application.yaml"]
else:
    _kustomization["resources"] = ["argocd-ns.yaml"] + _kustomization["resources"]
    yaml.dump_to_file(_argocd_custom_ns, "${_output_folder}/gitopscontroller/argocd-ns.yaml")

yaml.dump_to_file(_in_cluster, "${_output_folder}/gitopscontroller/in-cluster.yaml")
yaml.dump_to_file(_kustomization, "${_output_folder}/gitopscontroller/kustomization.yaml")
if _generate_crd_kustomization:
    yaml.dump_to_file(_crd_kustomization, "${_output_folder}/crds/kustomization.yaml")
