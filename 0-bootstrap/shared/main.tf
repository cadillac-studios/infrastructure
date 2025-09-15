locals {
  parent = var.parent_folder != "" ? "folders/${var.parent_folder}" : "organizations/${var.org_id}"
}

module "org_iam" {
  source          = "github.com/GoogleCloudPlatform/cloud-foundation-fabric/modules/organization?ref=v44.1.0"
  organization_id = "organizations/${var.org_id}"
  iam_by_principals = {
    "group:${var.groups.required_groups.group_billing_admins}" = [
      "roles/billing.creator",
    ]
  }
  iam_by_principals_additive = {
    "group:${var.groups.required_groups.group_org_admins}" = [
      "roles/serviceusage.serviceUsageConsumer",
      "roles/billing.user",
      "roles/resourcemanager.organizationAdmin",
      "roles/resourcemanager.projectCreator",
      "roles/storage.admin",
    ],
    "group:${var.groups.required_groups.group_billing_admins}" = [
      "roles/billing.admin",
    ]
  }
}

resource "google_folder" "bootstrap" {
  display_name = "${var.folder_prefix}-bootstrap"
  parent       = local.parent

  deletion_protection = var.folder_deletion_protection
}

resource "random_id" "seed_project_suffix" {
  byte_length = 2
}

module "seed_bootstrap" {
  source           = "github.com/GoogleCloudPlatform/cloud-foundation-fabric/modules/project?ref=v44.1.0"
  name             = "${var.project_prefix}-b-seed-${random_id.seed_project_suffix.hex}"
  descriptive_name = "${var.project_prefix}-b-seed"
  lien_reason      = "Project Factory lien"
  parent           = google_folder.bootstrap.id
  billing_account  = var.billing_account
  services = [
    "serviceusage.googleapis.com",
    "servicenetworking.googleapis.com",
    "cloudkms.googleapis.com",
    "compute.googleapis.com",
    "logging.googleapis.com",
    "bigquery.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "cloudbilling.googleapis.com",
    "cloudbuild.googleapis.com",
    "iam.googleapis.com",
    "admin.googleapis.com",
    "appengine.googleapis.com",
    "storage-api.googleapis.com",
    "monitoring.googleapis.com",
    "pubsub.googleapis.com",
    "securitycenter.googleapis.com",
    "accesscontextmanager.googleapis.com",
    "billingbudgets.googleapis.com",
    "essentialcontacts.googleapis.com",
    "assuredworkloads.googleapis.com",
    "cloudasset.googleapis.com",
    "orgpolicy.googleapis.com",
    "sqladmin.googleapis.com",
    "iamcredentials.googleapis.com",
  ]
  labels = {
    environment      = "bootstrap"
    application_name = "seed-bootstrap"
    business_code    = "shared"
    env_code         = "b"
    vpc              = "none"
  }
  service_config = {
    disable_on_destroy         = false
    disable_dependent_services = true
  }
  service_agents_config = {
    create_primary_agents = false
    grant_default_roles   = false
  }
  deletion_policy         = var.project_deletion_policy
  default_service_account = "disable"
  org_policies = {
    "iam.disableCrossProjectServiceAccountUsage" = {
      rules = [
        {
          enforce = false
        }
      ]
    }
  }
  iam = {
    "roles/editor" = []
  }

  depends_on = [module.required_group]
}

# KMS service for encrypting tf state buckets
# use defult_region_2 (currently set as 'asia-southeast1' ) as   
# default_region (asia-east2 (HK)) does not asia multi-regional bucket  
module "kms" {
  source     = "github.com/GoogleCloudPlatform/cloud-foundation-fabric/modules/kms?ref=v44.1.0"
  project_id = module.seed_bootstrap.project_id
  keyring = {
    location = var.default_region_2
    name     = "prj-keyring"
  }
  keys = {
    prj-key = {
      rotation_period = "7776000s"
      iam = {
        "roles/cloudkms.cryptoKeyDecrypter" = [
          "serviceAccount:service-${module.seed_bootstrap.number}@gs-project-accounts.iam.gserviceaccount.com",
        ]
        "roles/cloudkms.cryptoKeyEncrypter" = [
          "serviceAccount:service-${module.seed_bootstrap.number}@gs-project-accounts.iam.gserviceaccount.com",
        ]
      }
    }
  }
}

resource "random_id" "gh_cicd_project_suffix" {
  byte_length = 2
}

module "gh_cicd" {
  source           = "github.com/GoogleCloudPlatform/cloud-foundation-fabric/modules/project?ref=v44.1.0"
  name             = "${var.project_prefix}-b-cicd-wif-gh-${random_id.gh_cicd_project_suffix.hex}"
  descriptive_name = "${var.project_prefix}-b-cicd-wif-gh"
  parent           = google_folder.bootstrap.id
  billing_account  = var.billing_account
  services = [
    "compute.googleapis.com",
    "admin.googleapis.com",
    "iam.googleapis.com",
    "billingbudgets.googleapis.com",
    "cloudbilling.googleapis.com",
    "serviceusage.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "iamcredentials.googleapis.com",
  ]
  deletion_policy = var.project_deletion_policy
  service_config = {
    disable_on_destroy         = true
    disable_dependent_services = true
  }
  default_service_account = "disable"
  iam = {
    "roles/editor" = []
  }
}
