terraform {
  backend "gcs" {
    bucket                      = "bkt-prj-b-seed-tfstate-9ed1"
    prefix                      = "terraform/bootstrap/shared"
    impersonate_service_account = "sa-terraform-bootstrap@prj-b-seed-d9de.iam.gserviceaccount.com"
  }
}
