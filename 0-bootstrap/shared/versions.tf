terraform {
  required_version = ">= 0.13"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.42.0"
    }

    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 6.42.0"
    }

    # github = {
    #   source  = "integrations/github"
    #   version = ">= 5.0"
    # }
  }
}
