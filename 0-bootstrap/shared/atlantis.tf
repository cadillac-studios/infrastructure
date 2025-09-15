resource "random_id" "atlantis_project_suffix" {
  byte_length = 2
}

module "atlantis_project" {
  source           = "github.com/GoogleCloudPlatform/cloud-foundation-fabric/modules/project?ref=v44.1.0"
  name             = "${var.project_prefix}-b-atlantis-${random_id.atlantis_project_suffix.hex}"
  descriptive_name = "${var.project_prefix}-b-atlantis"
  parent           = google_folder.bootstrap.id
  billing_account  = var.billing_account
  services = [
    "serviceusage.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "secretmanager.googleapis.com",
    "compute.googleapis.com",
    "iap.googleapis.com",
    "artifactregistry.googleapis.com",
    "iamcredentials.googleapis.com",
  ]
  deletion_policy = var.project_deletion_policy
  service_config = {
    disable_on_destroy         = true
    disable_dependent_services = true
  }
  default_service_account = "disable"
}

module "sa_atlantis" {
  source     = "github.com/GoogleCloudPlatform/cloud-foundation-fabric/modules/iam-service-account?ref=v44.1.0"
  project_id = module.atlantis_project.project_id
  name       = "sa-atlantis"
  iam_project_roles = {
    (module.atlantis_project.project_id) = [
      "roles/secretmanager.secretAccessor",
      "roles/logging.logWriter",
      "roles/monitoring.metricWriter",
    ]
  }
}

module "atlantis_secrets" {
  source     = "github.com/GoogleCloudPlatform/cloud-foundation-fabric/modules/secret-manager?ref=v44.1.0"
  project_id = module.atlantis_project.project_id
  secrets = {
    tf-var-gh-token   = {}
    gh-app-key        = {}
    gh-webhook-secret = {}
  }
}

module "atlantis_vpc" {
  source     = "github.com/GoogleCloudPlatform/cloud-foundation-fabric/modules/net-vpc?ref=v44.1.0"
  project_id = module.atlantis_project.project_id
  name       = "atlantis-vpc"
  subnets = [
    {
      ip_cidr_range = "10.0.0.0/24"
      name          = "production"
      region        = var.default_region_2
    },
  ]
}

module "atlantis_nat" {
  source         = "github.com/GoogleCloudPlatform/cloud-foundation-fabric/modules/net-cloudnat?ref=v44.1.0"
  project_id     = module.atlantis_project.project_id
  region         = var.default_region_2
  router_network = module.atlantis_vpc.self_link
  name           = "atlantis-nat"
}

module "atlantis_registry" {
  source = "github.com/GoogleCloudPlatform/cloud-foundation-fabric/modules/artifact-registry?ref=v44.1.0"

  project_id = module.atlantis_project.project_id
  name       = "atlantis-registry"
  location   = var.default_region_2

  format = {
    docker = {
      standard = {}
    }
  }

  iam = {
    "roles/artifactregistry.reader" = [
      "serviceAccount:${module.sa_atlantis.email}",
    ]
  }
}

# resource "google_compute_security_policy" "atlantis" {
#   name        = "atlantis-security-policy"
#   description = "Policy blocking all traffic except from Github Webhooks"
#   project     = module.atlantis_project.project_id
#
#   rule {
#     # Allow from GitHub Webhooks
#     # https://api.github.com/meta
#     action      = "allow"
#     priority    = "2"
#     description = "Rule: Allow github hooks"
#     match {
#       expr {
#         expression = "(inIpRange(origin.ip, '140.82.112.0/20') || inIpRange(origin.ip, '185.199.108.0/22') || inIpRange(origin.ip, '143.55.64.0/20') || inIpRange(origin.ip, '192.30.252.0/22'))"
#       }
#     }
#   }
#
#   rule {
#     # Deny all by default
#     action      = "deny(403)"
#     priority    = "2147483647"
#     description = "Default rule: deny all"
#
#     match {
#       versioned_expr = "SRC_IPS_V1"
#       config {
#         src_ip_ranges = ["*"]
#       }
#     }
#   }
#
#   rule {
#     # Log4j vulnerability
#     action      = "deny(403)"
#     priority    = "1"
#     description = "CVE-2021-44228 (https://nvd.nist.gov/vuln/detail/CVE-2021-44228)"
#     match {
#       expr {
#         expression = "evaluatePreconfiguredExpr('cve-canary')"
#       }
#     }
#   }
# }
#
# resource "google_iap_brand" "atlantis" {
#   support_email     = module.sa_bootstrap.email
#   application_title = "Atlantis (The Cadillac Studio)"
#   project           = module.atlantis_project.project_id
# }
#
# resource "google_iap_client" "atlantis" {
#   display_name = "iap-client"
#   brand        = google_iap_brand.atlantis.id
# }
#
# module "atlantis" {
#   source = "github.com/runatlantis/terraform-gce-atlantis?ref=9e3811e1c334a95a12a6428a915145f481ce863e"
#
#   name       = "atlantis"
#   network    = module.atlantis_vpc.name
#   subnetwork = module.atlantis_vpc.subnets["${var.default_region_2}/production"].name
#   region     = var.default_region_2
#   zone       = "${var.default_region_2}-a"
#   service_account = {
#     email  = module.sa_atlantis.email
#     scopes = ["cloud-platform"]
#   }
#   env_vars = {
#     ATLANTIS_ATLANTIS_URL                = "https://atlantis.thecadillacstudio.com"
#     ATLANTIS_REPO_ALLOWLIST              = "github.com/cadillac-studios/infrastructure"
#     ATLANTIS_ALLLOW_COMMANDS             = "all"
#     ATLANTIS_GH_APP_ID                   = "1221135"
#     ATLANTIS_WRITE_GIT_CREDS             = "true"
#     ATLANTIS_PARALLEL_PLAN               = "true"
#     ATLANTIS_PARALLEL_APPLY              = "true"
#     ATLANTIS_ENABLE_DIFF_MARKDOWN_FORMAT = "true"
#     ATLANTIS_REPO_CONFIG_JSON = jsonencode({
#       "repos" : [
#         {
#           "id" : "github.com/cadillac-studios/infrastructure",
#           "branch" : "/^main$/",
#           "apply_requirements" : [
#             "mergeable",
#             "undiverged"
#           ],
#           "autodiscover" : {
#             "mode" : "auto"
#           }
#         }
#       ]
#     })
#   }
#   domain  = "atlantis.thecadillacstudio.com"
#   project = module.atlantis_project.project_id
#
#   default_backend_security_policy = google_compute_security_policy.atlantis.name
#
#   iap = {
#     oauth2_client_id     = google_iap_client.atlantis.client_id
#     oauth2_client_secret = google_iap_client.atlantis.secret
#   }
#
#   # Built and manually pushed to registry from atlantis.Dockerfile
#   image   = "${module.atlantis_registry.url}/runatlantis/atlantis:dev-alpine-6c12919"
#   command = ["/home/atlantis/custom-entrypoint.sh"]
#   args    = ["server"]
#
#   startup_script = templatefile("${path.module}/atlantis-entrypoint.tftpl", {
#     cloud_sdk_version          = "518.0.0"
#     app_key_secret_name        = "gh-app-key"
#     webhook_secret_secret_name = "gh-webhook-secret"
#     gh_token_secret_name       = "tf-var-gh-token"
#     mount_folder               = "/mnt/disks/gce-containers-mounts/gce-persistent-disks/atlantis-disk-0"
#     entrypoint_filename        = "custom-entrypoint.sh"
#   })
#
#   machine_type   = "e2-small"
#   enable_oslogin = true
# }
#
# resource "google_iap_web_backend_service_iam_member" "atlantis_access" {
#   project             = module.atlantis_project.project_id
#   web_backend_service = module.atlantis.iap_backend_service_name
#   role                = "roles/iap.httpsResourceAccessor"
#   member              = "gcp-organization-admins@thecadillacstudio.com"
# }
