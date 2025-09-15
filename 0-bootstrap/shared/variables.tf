variable "org_id" {
  description = "GCP Organization ID"
  type        = string
}

variable "billing_account" {
  description = "The ID of the billing account to associate projects with."
  type        = string
}

variable "default_region" {
  description = "Default region to create resources where applicable."
  type        = string
  default     = "asia-east2"
}

variable "default_region_2" {
  description = "Secondary default region to create resources where applicable."
  type        = string
  default     = "asia-southeast1"
}

variable "default_region_gcs" {
  description = "Case-Sensitive default region to create gcs resources where applicable."
  type        = string
  default     = "ASIA"
}

variable "default_region_kms" {
  description = "Secondary default region to create kms resources where applicable."
  type        = string
  default     = "asia"
}

variable "parent_folder" {
  description = "Optional - for an organization with existing projects or for development/validation. It will place all the example foundation resources under the provided folder instead of the root organization. The value is the numeric folder ID. The folder must already exist."
  type        = string
  default     = ""
}

variable "project_prefix" {
  description = "Name prefix to use for projects created. Should be the same in all steps. Max size is 3 characters."
  type        = string
  default     = "prj"
}

variable "folder_prefix" {
  description = "Name prefix to use for folders created. Should be the same in all steps."
  type        = string
  default     = "fldr"
}

variable "bucket_prefix" {
  description = "Name prefix to use for state bucket created."
  type        = string
  default     = "bkt"
}

variable "bucket_force_destroy" {
  description = "When deleting a bucket, this boolean option will delete all contained objects. If false, Terraform will fail to delete buckets which contain objects."
  type        = bool
  default     = false
}

variable "project_deletion_policy" {
  description = "The deletion policy for the project created."
  type        = string
  default     = "PREVENT"
}

variable "folder_deletion_protection" {
  description = "Prevent Terraform from destroying or recreating the folder."
  type        = string
  default     = true
}

/* ----------------------------------------
    Specific to Groups creation
   ---------------------------------------- */

variable "groups" {
  description = "Contain the details of the Groups to be created."
  type = object({
    create_required_groups = optional(bool, false)
    create_optional_groups = optional(bool, false)
    billing_project        = optional(string, null)
    required_groups = object({
      group_org_admins     = string
      group_billing_admins = string
      billing_data_users   = string
      audit_data_users     = string
      developers           = string
    })
    optional_groups = optional(object({
      gcp_security_reviewer    = optional(string, "")
      gcp_network_viewer       = optional(string, "")
      gcp_scc_admin            = optional(string, "")
      gcp_global_secrets_admin = optional(string, "")
      gcp_kms_admin            = optional(string, "")
    }), {})
  })

  validation {
    condition     = var.groups.create_required_groups || var.groups.create_optional_groups ? (var.groups.billing_project != null ? true : false) : true
    error_message = "A billing_project must be passed to use the automatic group creation."
  }

  validation {
    condition     = var.groups.required_groups.group_org_admins != ""
    error_message = "The group group_org_admins is invalid, it must be a valid email"
  }

  validation {
    condition     = var.groups.required_groups.group_billing_admins != ""
    error_message = "The group group_billing_admins is invalid, it must be a valid email"
  }

  validation {
    condition     = var.groups.required_groups.billing_data_users != ""
    error_message = "The group billing_data_users is invalid, it must be a valid email"
  }

  validation {
    condition     = var.groups.required_groups.audit_data_users != ""
    error_message = "The group audit_data_users is invalid, it must be a valid email"
  }
}

variable "initial_group_config" {
  description = "Define the group configuration when it is initialized. Valid values are: WITH_INITIAL_OWNER, EMPTY and INITIAL_GROUP_CONFIG_UNSPECIFIED."
  type        = string
  default     = "WITH_INITIAL_OWNER"
}

# variable "gh_token" {
#   description = "A fine-grained personal access token for the user or organization. See https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token#creating-a-fine-grained-personal-access-token"
#   type        = string
#   sensitive   = true
# }
