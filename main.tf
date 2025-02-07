module "db_module" {
  source = "/db"
}

module "ecs_module" {
  source                 = "/ecs"
  api_role_password      = module.db_module.api_role_password
  ingestor_role_password = module.db_module.ingestor_role_password
  insights_role_username = module.db_module.insights_role_password
}