resource "snowflake_account_role" "dbt_role" {
  name = "DBT_ROLE"
}

resource "snowflake_account_role" "matillion_role" {
  name = "MATILLION_ROLE"
}

# Roles that need access to databases and schemas
locals {
  database_access_roles = [
    snowflake_account_role.dbt_role.name,
    "ACCOUNTADMIN",
    snowflake_account_role.matillion_role.name
  ]
}

# Grant role access to each database for multiple roles
resource "snowflake_grant_privileges_to_account_role" "database_access" {
  for_each = {
    for item in setproduct(var.environments, local.database_access_roles) : 
    "${item[0]}_${item[1]}" => {
      env  = item[0]
      role = item[1]
    }
  }
  
  privileges        = ["USAGE"]
  account_role_name = each.value.role
  
  on_account_object {
    object_type = "DATABASE"
    object_name = snowflake_database.env_databases[each.value.env].name
  }
}

# Grant role access to each schema using the actual schema resources
resource "snowflake_grant_privileges_to_account_role" "schema_access" {
  for_each = {
    for item in flatten([
      for schema_key, schema in snowflake_schema.env_schemas : [
        for role in local.database_access_roles : {
          key    = "${schema_key}_${role}"
          schema = schema
          role   = role
        }
      ]
    ]) : item.key => item
  }
  
  privileges        = ["USAGE", "CREATE TABLE", "CREATE VIEW"]
  account_role_name = each.value.role
  
  on_schema {
    schema_name = "${each.value.schema.database}.${each.value.schema.name}"
  }
  
  depends_on = [snowflake_grant_privileges_to_account_role.database_access]
}

# Grant schema privileges to account admin role
resource "snowflake_grant_privileges_to_account_role" "account_admin_schemas" {
  for_each = snowflake_schema.env_schemas  # Use the actual schema resources
  privileges        = ["ALL"]
  account_role_name = "ACCOUNTADMIN"

  on_schema {
    # Fully qualified name: DATABASE.SCHEMA
    schema_name = "${each.value.database}.${each.value.name}"
  }
  depends_on = [snowflake_grant_privileges_to_account_role.database_access]
}

# future in schema
resource "snowflake_grant_privileges_to_account_role" "dbt_role_future_tables" {
  for_each = snowflake_schema.env_schemas  # Use the actual schema resources
  privileges        = ["ALL"]
  account_role_name = snowflake_account_role.dbt_role.name
  on_schema_object {
    future {
      object_type_plural = "TABLES"
      in_schema          = "${each.value.database}.${each.value.name}"
    }
  }
  depends_on = [snowflake_grant_privileges_to_account_role.database_access]
}



# future schemas in database
# resource "snowflake_grant_privileges_to_account_role" "example" {
#   privileges        = ["USAGE", "CREATE TABLE", "CREATE VIEW"]
#   account_role_name = snowflake_account_role.dbt_role.name
#   on_schema {
#     future_schemas_in_database = snowflake_database.db.name
#   }
# }