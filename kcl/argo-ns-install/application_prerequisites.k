_application_ns_resources = lambda _app_name: str, _argo_namespace: str, _namespace: str {
    resources = [
        {
            apiVersion = "v1"
            kind = "Namespace"
            metadata = {
                name = _namespace
            }
        }
        {
            apiVersion = "rbac.authorization.k8s.io/v1"
            kind = "Role"
            metadata = {
                namespace = _namespace
                name = "argocd-role"
            }
            rules = [
                {
                    apiGroups = [
                        "*"
                    ]
                    resources = [
                        "*"
                    ]
                    verbs = [
                        "*"
                    ]
                }
            ]
        }
        {
            apiVersion = "rbac.authorization.k8s.io/v1"
            kind = "RoleBinding"
            metadata = {
                namespace = _namespace
                name = "argocd-role-binding"
            }
            subjects = [
                {
                    kind = "ServiceAccount"
                    name = "argocd-application-controller"
                    namespace = _argo_namespace
                }
            ]
            roleRef = {
                kind = "Role"
                name = "argocd-role"
                apiGroup = "rbac.authorization.k8s.io"
            }
        }
        {
            apiVersion = "argoproj.io/v1alpha1"
            kind = "AppProject"
            metadata = {
                name = _app_name
                namespace = _argo_namespace
            }
            spec = {
                destinations = [
                    {
                        namespace = _namespace
                        server = "https://kubernetes.default.svc"
                    }
                ]
                sourceRepos = [
                    "*"
                ]
                namespaceResourceWhitelist = [
                    {
                        group = "*"
                        kind = "*"
                    }
                ]
            }
        }
    ]
}