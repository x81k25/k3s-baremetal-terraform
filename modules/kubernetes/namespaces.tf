resource "kubernetes_namespace" "argocd_test" {
  metadata {
    name = "argocd-test"
    labels = {
      managed-by = "terraform"
    }
  }
}

resource "kubernetes_namespace" "postgres" {
  metadata {
    name = "postgres"
    labels = {
      managed-by = "terraform"
    }
  }
}

resource "kubernetes_namespace" "automatic_transmission" {
  metadata {
    name = "automatic-transmission"
    labels = {
      managed-by = "terraform"
    }
  }
}