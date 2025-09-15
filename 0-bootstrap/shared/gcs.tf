resource "random_id" "gcs_bucket_tfstate_suffix" {
  byte_length = 2
}

# 1. First bucket (gcs_bucket_tfstate): Stores the bootstrap layer's own Terraform state (0-bootstrap, 1-org, 2-env, 3-net)
# 2. Second bucket (gcs_bucket_projects_tfstate): Stores state for all project-level configurations (4-proj, 5-sec, 6-producer, 7-app-net, 8-consumer)
# seperation of concern to avoid circular dependencies, 
# bootstrap store the tfstate of of infrastructure that manages the project bucket 

module "gcs_bucket_tfstate" {
  source = "github.com/GoogleCloudPlatform/cloud-foundation-fabric/modules/gcs?ref=v44.1.0"
  # source         = "../../ref/cloud-foundation-fabric-44.1.0/modules/gcs" # @DANGER Change Bck to above before use 
  name           = "${var.bucket_prefix}-${var.project_prefix}-b-seed-tfstate-${random_id.gcs_bucket_tfstate_suffix.hex}"
  location       = var.default_region_2
  project_id     = module.seed_bootstrap.project_id
  encryption_key = module.kms.keys["prj-key"].id
}

module "gcs_bucket_projects_tfstate" {
  source         = "github.com/GoogleCloudPlatform/cloud-foundation-fabric/modules/gcs?ref=v44.1.0"
  name           = "${var.bucket_prefix}-${module.seed_bootstrap.project_id}-gcp-projects-tfstate"
  location       = var.default_region_2
  project_id     = module.seed_bootstrap.project_id
  encryption_key = module.kms.keys["prj-key"].id
}
