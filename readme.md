# Terragrunt AWS Infrastructure as Code

A production-ready Terragrunt configuration for managing multi-environment AWS infrastructure following the DRY (Don't Repeat Yourself) principle.

## 📋 Quick Start

**Prerequisites:**

- Terraform (>= 1.5.0, <= 1.14.8)
- Terragrunt (latest)
- AWS CLI v2
- AWS Account with permissions

**Installation:** See [DETAILED_GUIDE.md](DETAILED_GUIDE.md#%EF%B8%8F-installation-guide-windows) for Windows setup instructions.

## 🚀 Getting Started 

1. **Clone the repository:**

```bash
git clone https://github.com/yourusername/terragrunt-aws-infrastructure.git
cd terragrunt-aws-infrastructure
```

2. **Configure AWS S3 backend** in [live/root.hcl](live/root.hcl):

```hcl
bucket = "YOUR-S3-BUCKET-NAME"
```

3. **Plan infrastructure:**

```bash
cd live
terragrunt run-all plan
```

4. **Deploy infrastructure:**

```bash
terragrunt run-all apply
```

## 📁 Project Structure

```
live/                    # Environment configurations
├── root.hcl            # Shared configuration
├── dev/                # Development environment
│   ├── vpc/
│   └── ec2/
└── prod/               # Production environment
    ├── vpc/
    └── ec2/

modules/                # Reusable Terraform modules
├── vpc/
└── ec2/

test/                   # Module testing folder
```

## 🛠 Common Commands

```bash
cd live

# Validate all configurations
terragrunt run-all validate

# Plan changes
terragrunt run-all plan

# Apply changes
terragrunt run-all apply

# Destroy infrastructure
terragrunt run-all destroy
```

## 📚 Documentation

For detailed information, see:

- **[DETAILED_GUIDE.md](DETAILED_GUIDE.md)** - In-depth documentation including:
  - What is Terragrunt and why use it?
  - Complete Windows installation guide
  - Architecture details
  - Best practices
  - Security considerations
  - Troubleshooting

## 🔐 Important Security Notes

- Never commit AWS credentials to Git
- Always use remote state (S3, TerraformCloud)
- Add `.gitignore` entries:
  ```
  .terraform/
  *.tfstate
  terraform.tfvars
  .terragrunt-cache/
  ```

## ⚠️ Disclaimer

Review infrastructure changes carefully before applying. Understand AWS billing before deployment.
root.hcl because Terragrunt uses:

`hcl
find_in_parent_folders("root.hcl")
`

This function searches upward recursively through parent directories until it finds
root.hcl and stops.

### Example root.hcl

`hcl
generate "provider" {
path = "provider.tf"
if_exists = "overwrite"
contents = <<EOF
terraform {
required_providers {
aws = {
source = "hashicorp/aws"
version = "~> 6.0"
}
}
required_version = ">= 1.5.0, <= 1.14.8"
}

provider "aws" {
region = "ap-south-2"
}
EOF
}

remote_state {
backend = "s3"
config = {
bucket = "s3-terraform-backend-files-hyderabad"
key = "}{path_relative_to_include()}/terragrunt/terraform.tfstate"
region = "ap-south-2"
}

generate = {
path = "backend.tf"
if_exists = "overwrite_terragrunt"
}
}
`


> **Note:** The file name can be anything—it doesn't have to be
> root.hcl

---

## Service Configuration Example

Within each service file, you can configure it as follows:

`hcl
include "root" {
path = find_in_parent_folders("root.hcl")
}

terraform {
source = "../../../modules/ec2"
}

dependency "vpc" {
config_path = "../vpc"
}

inputs = {
instance_type = "t3.micro"
tags = {
Name = "dev-ec2"
tag2 = "value2"
}
subnet_id = dependency.vpc.outputs.subnet_id
ami_id = "ami-0411ab208c7da4382"
}
`

---

## Common Commands

`bash
terragrunt init       # Initialize Terragrunt
terragrunt validate   # Validate configuration
terragrunt plan       # Preview changes
terragrunt apply      # Apply configuration
terragrunt apply --all # Apply all resources in directory
terragrunt destroy    # Destroy resources
terragrunt destroy --all # Destroy all resources in directory
`

> **Note:** Running erragrunt apply --all in the /prod directory will create all resources (EC2, VPC, etc.) within that environment
