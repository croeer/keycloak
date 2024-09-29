remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket = "${get_env("TG_STATEBUCKET", "")}"

    key = "${path_relative_to_include()}/terraform.tfstate"
    region         = "eu-central-1"
    encrypt        = true
    dynamodb_table = "tf-lock-table"
  }
}
generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
terraform {
  required_providers {
    keycloak = {
      source  = "mrparkers/keycloak"
      version = "4.4.0"
    }
  }
}

variable "CLIENT_SECRET" {
  type = string
}

variable "IDP_HOSTNAME" {
  type = string
}

provider "keycloak" {
  client_id     = "terraform"
  client_secret = var.CLIENT_SECRET
  url           = var.IDP_HOSTNAME
}

EOF
}