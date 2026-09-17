module "vpc" {
  source = "./modules/vpc"

  project_name = var.project_name
}

module "ecr" {
  source = "./modules/ecr"

  repository_name = "it-tools-ecs"
}
module "acm" {
  source = "./modules/acm"

  domain_name = var.domain_name
  zone_name   = var.domain_name
}

module "alb" {
  source = "./modules/alb"

  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  certificate_arn   = module.acm.certificate_arn
}

module "ecs" {
  source = "./modules/ecs"

  vpc_id                = module.vpc.vpc_id
  public_subnet_ids     = module.vpc.public_subnet_ids
  alb_security_group_id = module.alb.security_group_id
  target_group_arn      = module.alb.target_group_arn
  ecr_repository_url    = module.ecr.repository_url
  aws_region            = "eu-west-2"
}

resource "aws_route53_record" "app" {
  zone_id = module.acm.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = module.alb.alb_dns_name
    zone_id                = module.alb.alb_zone_id
    evaluate_target_health = true
  }
}