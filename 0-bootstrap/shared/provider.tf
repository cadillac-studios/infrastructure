provider "google" {
  user_project_override       = true
  # billing_project             = var.groups.billing_project
  impersonate_service_account = "sa-terraform-bootstrap@prj-b-seed-d9de.iam.gserviceaccount.com"
}

provider "google-beta" {
  user_project_override       = true
  billing_project             = var.groups.billing_project
  impersonate_service_account = "sa-terraform-bootstrap@prj-b-seed-d9de.iam.gserviceaccount.com"
}
