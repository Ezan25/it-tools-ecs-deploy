module "vpc" {
  source = "./modules/vpc"

  project_name = var.project_name
}

module "ecr" {
  source = "./modules/ecr"

  repository_name = "it-tools-ecs"
}
