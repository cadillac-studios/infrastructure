terraform {
  required_version = ">= 0.13"

  required_providers {
    google = {
      // version 4.31.0 removed because of issue https://github.com/hashicorp/terraform-provider-google/issues/12226
      source  = "hashicorp/google"
      version = ">= 3.50, != 4.31.0"
    }

    google-beta = {
      // version 4.31.0 removed because of issue https://github.com/hashicorp/terraform-provider-google/issues/12226
      source  = "hashicorp/google-beta"
      version = ">= 3.50, != 4.31.0"
    }

    # github = {
    #   source  = "integrations/github"
    #   version = ">= 5.0"
    # }
  }
}
