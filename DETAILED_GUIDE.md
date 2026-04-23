# Terragrunt AWS Infrastructure - Detailed Guide

This document contains detailed information about Terragrunt, installation, architecture, best practices, and more.

---

## 📦 What is Terragrunt?

> **Terragrunt** is a thin wrapper that provides extra tools for keeping your Terraform configurations DRY (Don't Repeat Yourself), working with multiple Terraform modules, and managing remote state.

### Why Use Terragrunt?

- **Reduce Code Duplication:** Write infrastructure configuration once, use it across multiple environments
- **Simplified Module Management:** Easily compose and reuse Terraform modules
- **Centralized Configuration:** Manage provider, backend, and common settings in one place
- **Dependency Management:** Automatically handle dependencies between infrastructure components
- **Multi-Environment Support:** Manage dev, staging, prod with minimal repetition
- **State Management:** Simplified remote state configuration and management

### Key Benefits

| Benefit                      | Description                                                                          |
| ---------------------------- | ------------------------------------------------------------------------------------ |
| **🔄 DRY Principle**         | Write configuration once instead of repeating it across environments                 |
| **🏗️ Module Reusability**    | Create reusable modules and share across multiple environments/projects              |
| **🔗 Dependency Tracking**   | Automatic handling of inter-resource dependencies                                    |
| **📊 Remote State**          | Centralized state management with S3, TerraformCloud, or other backends              |
| **🎯 Environment Isolation** | Separate configurations for dev, staging, production with shared infrastructure code |
| **⚡ Faster Development**    | Reduce boilerplate, deploy faster, maintain cleaner code                             |
| **🛡️ Consistency**           | Ensure all environments use the same provider versions and configurations            |
| **📈 Scalability**           | Easily scale to manage hundreds of infrastructure components                         |

---

## ⚙️ Installation Guide (Windows)

### Option 1: Using Chocolatey (Recommended)

#### Step 1: Install Chocolatey

If you don't have Chocolatey installed, open **PowerShell as Administrator** and run:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

#### Step 2: Install Terraform

```powershell
choco install terraform
```

#### Step 3: Install Terragrunt

```powershell
choco install terragrunt
```

#### Step 4: Install AWS CLI

```powershell
choco install awscli
```

#### Step 5: Verify Installation

```powershell
terraform --version
terragrunt --version
aws --version
```

---

### Option 2: Manual Installation

#### Step 1: Install Terraform

1. Visit [terraform.io/downloads](https://www.terraform.io/downloads.html)
2. Download the Windows 64-bit ZIP file
3. Extract to a folder (e.g., `C:\terraform`)
4. Add the folder to your **System PATH**
5. Verify: Open PowerShell and run `terraform --version`

#### Step 2: Install Terragrunt

1. Visit [terragrunt.gruntwork.io/docs/getting-started/install](https://terragrunt.gruntwork.io/docs/getting-started/install/)
2. Download the Windows binary
3. Rename it to `terragrunt.exe`
4. Save to a folder (e.g., `C:\terragrunt`)
5. Add the folder to your **System PATH**
6. Verify: Open PowerShell and run `terragrunt --version`

#### Step 3: Install AWS CLI

1. Visit [aws.amazon.com/cli](https://aws.amazon.com/cli/)
2. Download the Windows **MSI installer**
3. Run the installer and follow the prompts
4. Verify: Open PowerShell and run `aws --version`

---

### Step 6: Configure AWS Credentials

Open **PowerShell** and run:

```powershell
aws configure
```

You'll be prompted to enter:

- **AWS Access Key ID**
- **AWS Secret Access Key**
- **Default region:** `ap-south-2` (or your preferred region)
- **Default output format:** `json`

Alternatively, set environment variables:

```powershell
$env:AWS_ACCESS_KEY_ID = "YOUR_ACCESS_KEY"
$env:AWS_SECRET_ACCESS_KEY = "YOUR_SECRET_KEY"
$env:AWS_DEFAULT_REGION = "ap-south-2"
```

---

### Verify All Installations

```powershell
# Check all tools are installed
terraform -version
terragrunt -version
aws --version

# Test AWS connectivity
aws sts get-caller-identity
```

Expected output from AWS test:

```json
{
  "UserId": "AIDAI...",
  "Account": "123456789012",
  "Arn": "arn:aws:iam::123456789012:user/your-user"
}
```

---

## 📊 Architecture Details

### VPC Module

Creates an AWS VPC with a subnet.

**Inputs:**
| Variable | Type | Description | Required |
|----------|------|-------------|----------|
| `cidr_block` | string | CIDR block for the VPC | Yes |
| `subnet_cidr_block` | string | CIDR block for the subnet | Yes |
| `tags` | map(string) | Tags for VPC resource | No |
| `subnet_tags` | map(string) | Tags for subnet resource | No |

**Outputs:**

- `subnet_id`: The ID of the created subnet
- `vpc_id`: The ID of the created VPC

### EC2 Module

Launches an EC2 instance in a specified subnet.

**Inputs:**
| Variable | Type | Description | Required |
|----------|------|-------------|----------|
| `instance_type` | string | EC2 instance type | Yes |
| `ami_id` | string | AMI ID for the instance | Yes |
| `subnet_id` | string | Subnet ID to launch instance in | Yes |
| `tags` | map(string) | Tags for EC2 resource | No |

---

## 🔄 Environment-Specific Configurations

### Development Environment

- **VPC CIDR:** 10.0.0.0/16
- **Subnet CIDR:** 10.0.1.0/24
- **Instance Type:** t3.micro (cost-optimized)
- **Backend Key:** `dev/terragrunt/terraform.tfstate`

### Production Environment

- **VPC CIDR:** Configure as needed
- **Subnet CIDR:** Configure as needed
- **Instance Type:** Configure based on workload
- **Backend Key:** `prod/terragrunt/terraform.tfstate`

---

## 📝 Key Terragrunt Concepts

### Root Configuration (root.hcl)

The root file sets up:

- **Provider Generation:** AWS provider with specific version constraints
- **Remote State:** S3 backend for state management
- **Consistent Configuration:** Applied to all child modules

### Module Dependencies

EC2 module depends on VPC to obtain the subnet ID:

```hcl
dependency "vpc" {
  config_path = "../vpc"
}

inputs = {
  subnet_id = dependency.vpc.outputs.subnet_id
}
```

### Configuration Inheritance

Child `terragrunt.hcl` files include the root configuration:

```hcl
include "root" {
  path = find_in_parent_folders("root.hcl")
}
```

---

## 🛠 Common Commands

```bash
# Validate all configurations
cd live && terragrunt run-all validate

# Format all HCL files
terragrunt hclfmt --terragrunt-recursive

# Destroy infrastructure in reverse dependency order
cd live && terragrunt run-all destroy

# Show outputs
cd live/dev/vpc && terragrunt output

# Refresh state
terragrunt refresh
```

---

## 📚 Best Practices

1. **State Management:** Always use remote state (S3, TerraformCloud, etc.)
2. **Version Pinning:** Pin Terraform and provider versions to avoid surprises
3. **Testing:** Use the `test/` folder to validate modules before deployment
4. **Naming Conventions:** Use consistent naming across environments
5. **Tags:** Always tag resources for cost tracking and organization
6. **Secrets:** Never commit AWS credentials; use AWS profiles or IAM roles
7. **Code Review:** Implement PR reviews before applying infrastructure changes

---

## 🔐 Security Considerations

- Store sensitive data in AWS Secrets Manager or Parameter Store
- Use IAM roles instead of long-lived credentials
- Enable versioning on S3 backend bucket
- Enable server-side encryption on S3 backend
- Restrict access to Terraform state files
- Use `terraform.tfvars` for secrets (add to `.gitignore`)

**Add to .gitignore:**

```
.terraform/
.terraform.lock.hcl
*.tfstate
*.tfstate.*
.terragrunt-cache/
terraform.tfvars
*.auto.tfvars
```

---

## 📖 References

- [Terragrunt Documentation](https://terragrunt.gruntwork.io/)
- [Terraform Best Practices](https://www.terraform.io/docs/)
- [AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest)
- [Gruntwork Terragrunt Best Practices](https://docs.terragrunt.gruntwork.io/docs/)

---

## 📖 Additional Resources

- [Terragrunt Quick Start](https://docs.terragrunt.com/getting-started/quick-start/)
- [AWS CLI Documentation](https://docs.aws.amazon.com/cli/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
