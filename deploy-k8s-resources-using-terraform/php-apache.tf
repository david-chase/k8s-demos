resource "kubernetes_manifest" "namespace_testing" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "Namespace"
    "metadata" = {
      "name" = "testing"
    }
  }
}

resource "kubernetes_manifest" "deployment_testing_php_apache" {
  manifest = {
    "apiVersion" = "apps/v1"
    "kind" = "Deployment"
    "metadata" = {
      "name" = "php-apache"
      "namespace" = "testing"
    }
    "spec" = {
      "replicas" = 3
      "selector" = {
        "matchLabels" = {
          "app" = "demo"
        }
      }
      "template" = {
        "metadata" = {
          "labels" = {
            "app" = "demo"
          }
        }
        "spec" = {
          "containers" = [
            {
              "image" = "registry.k8s.io/hpa-example"
              "name" = "php-apache"
            },
          ]
        }
      }
    }
  }
}
