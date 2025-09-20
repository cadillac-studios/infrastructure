output "seed_project_id" {
  description = "Project where service accounts and core APIs will be enabled."
  value       = module.seed_bootstrap.project_id
}
#
# output "cicd_project_id" {
#   description = "Project where the CI/CD infrastructure for GitHub Action resides."
#   value       = module.gh_cicd.project_id
# }

output "bootstrap_step_terraform_service_account_email" {
  description = "Bootstrap Step Terraform Account"
  value       = module.sa_bootstrap.email
}

# output "organization_step_terraform_service_account_email" {
#   description = "Organization Step Terraform Account"
#   value       = module.sa_org.email
# }
#
# output "environment_step_terraform_service_account_email" {
#   description = "Environment Step Terraform Account"
#   value       = module.sa_env.email
# }
#
# output "networks_step_terraform_service_account_email" {
#   description = "Networks Step Terraform Account"
#   value       = module.sa_net.email
# }
#
# output "projects_step_terraform_service_account_email" {
#   description = "Projects Step Terraform Account"
#   value       = module.sa_proj.email
# }
#
# output "security_step_terraform_service_account_email" {
#   description = "Security Step Terraform Account"
#   value       = module.sa_sec.email
# }
#
# output "producer_step_terraform_service_account_email" {
#   description = "Producer Step Terraform Account"
#   value       = module.sa_producer.email
# }
#
# output "app_net_step_terraform_service_account_email" {
#   description = "App Net Step Terraform Account"
#   value       = module.sa_app_net.email
# }
#
# output "consumer_step_terraform_service_account_email" {
#   description = "Consumer Step Terraform Account"
#   value       = module.sa_consumer.email
# }

# output "backend_ci_service_account_email" {
#   description = "Backend CI Service Account"
#   value       = module.sa_backend_ci.email
# }

output "gcs_bucket_tfstate" {
  description = "Bucket used for storing terraform state for Foundations Pipelines in Seed Project."
  value       = module.gcs_bucket_tfstate.name
}

output "projects_gcs_bucket_tfstate" {
  description = "Bucket used for storing terraform state for stage 4-projects foundations pipelines in seed project."
  value       = module.gcs_bucket_projects_tfstate.name
}

output "common_config" {
  description = "Common configuration data to be used in other steps."
  value = {
    org_id                = var.org_id,
    parent_folder         = var.parent_folder,
    billing_account       = var.billing_account,
    default_region        = var.default_region,
    default_region_2      = var.default_region_2,
    default_region_gcs    = var.default_region_gcs,
    default_region_kms    = var.default_region_kms,
    project_prefix        = var.project_prefix,
    folder_prefix         = var.folder_prefix
    parent_id             = local.parent
    bootstrap_folder_name = google_folder.bootstrap.name
  }
}

output "required_groups" {
  description = "List of Google Groups created that are required by the Example Foundation steps."
  value       = var.groups.create_required_groups == false ? tomap(var.groups.required_groups) : tomap({ for key, value in module.required_group : key => value.id })
}

output "optional_groups" {
  description = "List of Google Groups created that are optional to the Example Foundation steps."
  value       = var.groups.create_optional_groups == false ? tomap(var.groups.optional_groups) : tomap({ for key, value in module.optional_group : key => value.id })
}
