org_id = "189037593606"

billing_account = "011559-E53C8C-98FF02"

groups = {
  create_required_groups = true
  billing_project        = "prj-b-bootstrap"
  required_groups = {
    group_org_admins     = "gcp-organization-admins@thecadillacstudio.com"
    group_billing_admins = "gcp-billing-admins@thecadillacstudio.com"
    billing_data_users   = "gcp-billing-data@thecadillacstudio.com"
    audit_data_users     = "gcp-audit-data@thecadillacstudio.com"
    developers           = "gcp-developers@thecadillacstudio.com"
  }
}

default_region     = "asia-east2"
default_region_2   = "asia-southeast1"
default_region_gcs = "ASIA"
default_region_kms = "asia"
