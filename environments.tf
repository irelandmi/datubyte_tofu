# Create databases for each environment
resource "snowflake_database" "env_databases" {
  for_each = toset(var.environments)
  
  name                        = upper("${var.project_name}_${each.value}")
  comment                     = "Database for ${each.value} environment - Managed by OpenTofu"
}

# Create schemas within each database
resource "snowflake_schema" "env_schemas" {
  for_each = {
    for item in flatten([
      for env in var.environments : [
        for schema in var.schemas : {
          key      = "${env}_${schema}"
          env      = env
          schema   = schema
          database = upper("${var.project_name}_${env}")
        }
      ]
    ]) : item.key => item
  }
  
  database            = snowflake_database.env_databases[each.value.env].name
  name                = upper(each.value.schema)
  comment             = "${each.value.schema} schema for ${each.value.env} environment - Managed by OpenTofu"
  depends_on = [snowflake_database.env_databases]
}