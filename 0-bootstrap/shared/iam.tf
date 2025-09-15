module "sa_bootstrap" {
  source     = "github.com/GoogleCloudPlatform/cloud-foundation-fabric/modules/iam-service-account?ref=v44.1.0"
  project_id = module.seed_bootstrap.project_id
  name       = "sa-terraform-bootstrap"
  iam = {
    "roles/iam.serviceAccountTokenCreator" = [
      "serviceAccount:sa-terraform-bootstrap@${module.seed_bootstrap.project_id}.iam.gserviceaccount.com",
      "serviceAccount:${module.sa_atlantis.email}",
    ]
  }
  iam_billing_roles = {
    (var.billing_account) = [
      "roles/billing.admin",
    ]
  }
  iam_organization_roles = {
    (var.org_id) = [
      "roles/browser",
      "roles/accesscontextmanager.policyAdmin",
      "roles/resourcemanager.organizationAdmin",
      "roles/serviceusage.serviceUsageAdmin",
      "roles/resourcemanager.folderAdmin",
      "roles/resourcemanager.projectCreator",
      "roles/orgpolicy.policyAdmin",
    ]
  }
  iam_project_roles = {
    (module.seed_bootstrap.project_id) = [
      "roles/cloudkms.admin",
      "roles/iam.serviceAccountAdmin",
      "roles/resourcemanager.projectDeleter",
      "roles/storage.admin",
      "roles/bigquery.jobUser",
      "roles/iam.workloadIdentityPoolAdmin",
    ],
    (module.gh_cicd.project_id) = [
      "roles/artifactregistry.admin",
      "roles/cloudbuild.builds.editor",
      "roles/cloudbuild.workerPoolOwner",
      "roles/cloudscheduler.admin",
      "roles/compute.networkAdmin",
      "roles/dns.admin",
      "roles/iam.serviceAccountAdmin",
      "roles/iam.workloadIdentityPoolAdmin",
      "roles/resourcemanager.projectDeleter",
      "roles/source.admin",
      "roles/storage.admin",
      "roles/workflows.admin",
    ]
  }
}

module "sa_org" {
  source     = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/iam-service-account?ref=v38.1.0"
  project_id = module.seed_bootstrap.project_id
  name       = "sa-terraform-org"
  iam = {
    "roles/iam.serviceAccountTokenCreator" = [
      "serviceAccount:sa-terraform-org@${module.seed_bootstrap.project_id}.iam.gserviceaccount.com",
      "serviceAccount:${module.sa_atlantis.email}",
    ]
  }
  iam_billing_roles = {
    (var.billing_account) = [
      "roles/billing.admin",
      "roles/logging.configWriter",
    ]
  }
  iam_organization_roles = {
    (var.org_id) = [
      "roles/browser",
      "roles/orgpolicy.policyAdmin",
      "roles/logging.configWriter",
      "roles/resourcemanager.organizationAdmin",
      "roles/securitycenter.notificationConfigEditor",
      "roles/resourcemanager.organizationViewer",
      "roles/accesscontextmanager.policyAdmin",
      "roles/essentialcontacts.admin",
      "roles/resourcemanager.tagAdmin",
      "roles/resourcemanager.tagUser",
      "roles/cloudasset.owner",
      "roles/securitycenter.sourcesEditor",
      "roles/resourcemanager.folderAdmin",
      "roles/resourcemanager.projectCreator",
      "roles/iam.organizationRoleAdmin",
    ]
  }
  iam_project_roles = {
    (module.seed_bootstrap.project_id) = [
      "roles/storage.objectAdmin",
    ],
  }
}
