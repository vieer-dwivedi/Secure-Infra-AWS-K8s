remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
  config = {
    bucket         = "${get_env("RESOURCE_PREFIX", "default-prefix")}-s3-state"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "${get_env("AWS_REGION", "us-west-2")}"
    encrypt        = true
    dynamodb_table = "${get_env("RESOURCE_PREFIX", "default-prefix")}-dynamo-state-lock-tb"
  }
}

generate "provider"{
	path = "provider.tf"
	if_exists = "overwrite_terragrunt"

	contents = <<EOF

	provider "aws"{
		region = "us-west-2"
		}
	EOF
}