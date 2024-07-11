# Project Name

This project uses Terraform and Terragrunt to manage AWS infrastructure.

## Project Structure

- **infra-modules**: Contains Terraform modules for various AWS resources.
  - **s3**: Terraform modules for S3 bucket configurations.
  - **cloudfront**: Terraform modules for CloudFront distributions.
  - **s3_bucket_policy**: Terraform modules for S3 bucket policies.

- **environments**: Contains Terragrunt configurations for different environments.
  - **dev**: Terragrunt configurations for the development environment.
  - **prod**: Terragrunt configurations for the production environment.

## Getting Started

1. Install Terraform and Terragrunt.
2. Set up AWS credentials.
3. Navigate to the desired environment folder in `environments`.
4. Run `terragrunt run-all init` to initialize the environment.
5. Run `terragrunt run-all plan` to see the planned infrastructure changes.
6. Run `terragrunt run-all apply` to apply the changes.

## Notes

- Ensure Terraform modules in `infra-modules` are up to date.
- Use Terragrunt to manage environments for easier configuration management.
- Follow best practices for AWS infrastructure security and cost optimization.
EOF
