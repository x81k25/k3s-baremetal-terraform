# k3s-baremetal-terraform

A Terraform project for deploying and managing a K3s Kubernetes cluster on bare metal servers.

## Overview

This project contains Terraform configurations to automate the deployment of a K3s cluster on local bare metal infrastructure. It uses the Rancher provider to manage K3s, along with configurations for Kubernetes resources like namespaces and providers.

## Repository Structure

```
.
├── .terraform           # Terraform working directory (gitignored)
├── modules
│   ├── argcd            # ArgoCD module
│   ├── k3s              # K3s cluster configuration 
│   ├── kubernetes       # Kubernetes resources
│   └── rancher          # Rancher provider configuration
├── providers.tf         # Provider configurations
├── main.tf              # Main Terraform configuration
├── variables.tf         # Variable declarations
└── outputs.tf           # Output definitions
```

## Prerequisites

- Terraform >= 1.0.0
- A bare metal server or local machine capable of running K3s
- Network connectivity between your deployment machine and target servers

## Configuration

This project uses variable files for configuration. You'll need to create your own variable files based on the structure in the `variables.tf` files throughout the project. All variables should be assigned in the `terraform.tfvars` file in the root directory. Global variables are defined in only the root `variables.tf`. Module variables are defined in the root `variables.tf` and in the module `variables.tf` files, and passed within the root `main.tf`.

## Usage

1. Clone this repository
2. Create a `terraform.tfvars` file with your specific configurations
3. Initialize Terraform:

```bash
terraform init
```

4. Plan your deployment:

```bash
terraform plan
```

5. Apply the configuration:

```bash
terraform apply
```

## Modules

#### Modularity and Customization
This project follows a highly modular design philosophy. Each module is self-contained with its own:

- main.tf - Core resources and logic
- variables.tf - Module-specific input variables
- outputs.tf - Exposed outputs for other modules
- providers.tf - Provider configurations (where applicable)

This modular approach provides several benefits:

- Independent Development: Each module can be developed, tested, and maintained independently
- Clean Organization: Resources are logically grouped, making the codebase easier to navigate
- Reusability: Modules can be reused across different environments or projects
- Customization: Users can easily replace or modify individual modules without affecting others
- Simplified Maintenance: Updates to one module don't require changes to others

#### Customizing for Your Environment
To customize this project:

1. Review all variables.tf files to understand required inputs
2. Create a terraform.tfvars file with your specific values
3. Modify or extend modules as needed for your specific infrastructure
4. Add or remove modules based on your requirements

### Current Modules

#### K3s

The K3s module (`modules/k3s`) manages the deployment and configuration of a K3s cluster on bare metal. It handles:

- Node configuration
- Networking setup
- Storage configuration

#### Kubernetes

The Kubernetes module (`modules/kubernetes`) creates and manages Kubernetes resources, including:

- Namespaces
- Provider configurations

#### Rancher

The Rancher module (`modules/rancher`) configures the interaction with K3s through the Rancher provider.

#### ArgoCD

The ArgoCD module (`modules/argcd`) sets up and configures ArgoCD for GitOps workflows.

## Customization

To customize this project for your environment:

1. Review all `variables.tf` files to understand required inputs
2. Create a `terraform.tfvars` file with your specific values
3. Modify or extend modules as needed for your specific infrastructure

## Notes

- This repository doesn't include sensitive data or state files
- All Terraform state is managed locally by default and excluded from git
- Custom mount points configuration is required for proper operation

## License

[MIT License](LICENSE)