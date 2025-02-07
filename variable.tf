variable "test" {
  description = "dummy variable"
  type        = string
  default     = "test"
}

variable "api_role_username" {
  default = "cpm_api"
}
variable "ingestion_role_username" {
  default = "cpm_ingestor"
}
variable "insights_role_username" {
  default = "cpm_insights"
}