variable "opentofu_snowflake_private_key" {
  type      = string
  sensitive = true
}

variable "opentofu_snowflake_organization_name" {
  type    = string
}

variable "opentofu_snowflake_account_name" {
  type    = string
}

variable "snowflake_user" {
  type    = string
  default = "OPENTOFU_USER"
}

variable "snowflake_role" {
  type    = string
  default = "OPENTOFU_ROLE"
}
  
variable "environments" {
  type = list(string)
  default = ["DEV", "QA", "PROD"]
}

variable "project_name" {
  type    = string
  default = "TOFU"
  description = "Project name used as prefix for resources"
}

variable "schemas" {
  type = list(string)
  default = [
    "BRONZE",
    "SILVER",
    "GOLD",
    "PLATINUM"
  ]
  description = "List of schemas to create in each database"
}

variable "warehouse_sizes" {
  type = map(string)
  default = {
    dev  = "X-SMALL"
    qa   = "X-SMALL"
    prod = "X-SMALL"
  }
  description = "Warehouse sizes for each environment"
}

variable "data_retention_days" {
  type = map(number)
  default = {
    dev  = 1
    qa   = 1
    prod = 1
  }
  description = "Data retention time in days for each environment"
}