# Understanding the Codebase

This repository is a Terragrunt-driven AWS infrastructure project. It is organized into:

- `live/` — environment-specific Terragrunt configurations
- `modules/` — reusable Terraform modules for AWS resources
- root files and docs for guidance and shared configuration

---
## Overall Architecture

- `live/` is the environment orchestration layer. It uses Terragrunt to wire together modules and to share provider/state configuration.
- `modules/` contains reusable Terraform code for AWS infrastructure components.
- Root documentation files explain usage, setup, and architecture.

This layout follows a common Terragrunt pattern: keep environment-specific values separate from reusable infrastructure code, and centralize shared settings in one parent `root.hcl`.

---

## Root Folder

### Files

- `readme.md`
  - A high-level overview of the project
  - Contains quick start instructions, prerequisites, recommended commands, and the basic project structure

- `DETAILED_GUIDE.md`
  - A longer guide that explains Terragrunt concepts, installation steps, architecture, environment design, and command usage
  - Includes examples for Windows installation, AWS credentials setup, and how Terragrunt inheritance works

- `.gitignore`
  - Git ignore rules for Terraform, Terragrunt, and local state/cache files

- `.git/`
  - Git repository metadata (not directly part of the infrastructure code logic)

---

## `live/`

This directory contains environment-specific Terragrunt configuration. It is where Terragrunt composes modules into complete deployments.

### `live/root.hcl`

- Shared parent configuration included by all child Terragrunt files
- Generates a `provider.tf` file with AWS provider settings
- Configures remote state in an S3 backend
- Uses:
  - `required_providers` for AWS version constraints
  - `required_version` for Terraform compatibility
  - `remote_state` backend config with an S3 bucket and path template
- It is the central point for provider and state configuration across `dev` and `prod`

### `live/dev/`

Contains the development environment configuration.

#### `live/dev/vpc/terragrunt.hcl`

- Includes the root configuration with `find_in_parent_folders("root.hcl")`
- Points Terraform at the `../../../modules/vpc` source
- Passes input values for:
  - `cidr_block`
  - `subnet_cidr_block`
  - `tags`
  - `subnet_tags`
- This defines the VPC and subnet for dev

#### `live/dev/ec2/terragrunt.hcl`

- Includes the root configuration
- Uses `../../../modules/ec2`
- Declares a dependency on the VPC module with `dependency "vpc" { config_path = "../vpc" }`
- Uses the VPC output `dependency.vpc.outputs.subnet_id` to attach the EC2 instance to the subnet
- Sends instance inputs such as `instance_type`, `ami_id`, and tags

### `live/prod/`

Contains the production environment configuration, mirroring `dev` structure.

#### `live/prod/vpc/terragrunt.hcl`

- Same pattern as dev VPC
- Defines production VPC inputs and tags

#### `live/prod/ec2/terragrunt.hcl`

- Same pattern as dev EC2
- Depends on the production VPC and injects its subnet ID into the EC2 module

---

## `modules/`

Reusable Terraform modules for AWS resources. These are the actual resource definitions that Terragrunt references.

### `modules/vpc/`

- `main.tf`
  - Defines an AWS VPC resource (`aws_vpc.main`)
  - Defines an AWS subnet resource (`aws_subnet.main`) inside that VPC
- `variables.tf`
  - Declares module inputs:
    - `cidr_block`
    - `tags`
    - `subnet_cidr_block`
    - `subnet_tags`
- `output.tf`
  - Exposes `subnet_id` so downstream modules can consume it

### `modules/ec2/`

- `main.tf`
  - Defines an AWS EC2 instance resource (`aws_instance.example`)
  - Uses inputs for instance type, AMI, subnet ID, and tags
- `variables.tf`
  - Declares module inputs:
    - `instance_type`
    - `ami_id`
    - `subnet_id`
    - `tags`

This module is intentionally simple and depends on external inputs for network placement and AMI selection.

