# k3s-baremetal-terraform

A comprehensive Terraform project for deploying and managing a K3s Kubernetes cluster on bare metal servers with integrated Rancher, ArgoCD, PostgreSQL, MLflow, and media services.

## Overview

This project contains Terraform configurations to automate the deployment of a full-featured K3s cluster on local bare metal infrastructure. It uses modular design to manage each component independently, including K3s installation, Rancher management, ArgoCD for GitOps, PostgreSQL databases, AI/ML tools, data orchestration with Dagster, and specialized media services including rear differential monitoring.

## Repository Structure

```
.
├── .terraform           # Terraform working directory (gitignored)
├── modules/
│   ├── ai-ml/           # AI/ML tools including MLflow
│   ├── argocd/          # ArgoCD GitOps deployment
│   ├── k3s/             # K3s cluster installation and configuration
│   ├── media/           # Media services (Plex, Dagster orchestration, rear_diff service)
│   ├── pgsql/           # PostgreSQL databases
│   └── rancher/         # Rancher management layer
├── .gitignore           # Git ignore patterns
├── providers.tf         # Provider configurations
├── main.tf              # Main Terraform configuration
├── variables.tf         # Variable declarations
└── outputs.tf           # Output definitions
```

## Features

- **Automated K3s Installation**: Single-node K3s deployment with customizable configuration
- **Rancher Integration**: Automated deployment of Rancher for cluster management
- **GitOps Ready**: Integrated ArgoCD for continuous deployment from Git repositories
- **Database Infrastructure**: PostgreSQL databases with pgAdmin4 web interface
- **AI/ML Platform**: MLflow tracking server with MinIO artifact store
- **Data Orchestration**: Dagster platform for data pipeline management and scheduling
- **Media Services**: Pre-configured media stack with GPU support including Plex media server
- **Automotive Services**: Rear differential monitoring and analysis service
- **Namespace Management**: Structured namespace provisioning with proper RBAC
- **Resource Quota Management**: Comprehensive namespace-level resource limits for all services
- **Container Registry Integration**: GitHub Container Registry authentication
- **Backup Configuration**: Built-in etcd snapshot backups
- **Network Customization**: Flexible network configuration options
- **Multi-environment Support**: Development, staging, and production environments for media and database services

## Dependencies

- A bare metal server with sufficient CPU, RAM, and storage
- (Optional) NVIDIA GPU for hardware acceleration in media services

### Terraform

``` bash
# Install required dependencies
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl

# Add HashiCorp GPG key
wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

# Add HashiCorp repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list

# Update repository list and install Terraform
sudo apt update && sudo apt install terraform
```

### kubectl

```bash
# Install prerequisites
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl

# Download the latest stable kubectl binary
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Make the kubectl binary executable
chmod +x kubectl

# Move the binary to the default location
sudo mv kubectl /usr/local/bin/

source ~/.bashrc

# Verify installation
kubectl version --client
```

### kubeconfig

```bash
# Add KUBECONFIG to .bashrc for persistence
echo 'export KUBECONFIG=/d/k8s/k3s.yaml' >> ~/.bashrc
```

## Configuration

This project uses variable files for configuration. You'll need to create a `terraform.tfvars` file based on the variables defined in `variables.tf`. Key configuration sections include:

### Global Configuration
- Server IP
- Mount points for persistent data
- Kubeconfig path
- GitHub credentials for container registry
- SSH configuration

### K3s Configuration
- Version
- Resource limits
- Network settings
- Backup configuration

### Rancher Configuration
- Version
- Hostname
- Ingress settings

### ArgoCD Configuration
- Version and namespace settings
- SSH-based Git repository access (replaces HTTPS authentication)
- GitHub Container Registry credentials (consolidated into secrets)
- Resource limits for server, repo-server, and application controller
- SSH private key path for Git operations
- Kubeconfig path (consolidated into configuration object)

### PostgreSQL Configuration
- Database credentials for dev/staging/prod environments
- pgAdmin4 configuration

### AI/ML Configuration
- MLflow server credentials
- Database connections
- MinIO artifact store configuration

### Media Services
- Plex claim token and configuration
- Dagster workspace and database configuration
- Rear differential service database connections
- VPN configuration
- GPU resource allocation
- Multi-environment settings (dev/staging/prod)

## Prerequisites

### SSH Key Setup for ArgoCD Git Repository Access

**Critical**: Before deploying ArgoCD, you must generate SSH keys for Git repository access:

1. Generate a dedicated SSH key pair for ArgoCD:
```bash
ssh-keygen -t ed25519 -C "argocd" -f ~/.ssh/argocd_ed25519
```

2. Add the public key to your GitHub account:
   - Navigate to GitHub Settings > SSH and GPG keys
   - Add new SSH key with the content of `~/.ssh/argocd_ed25519.pub`
   - Title: "ArgoCD Production Server"

3. Ensure the private key path is correctly referenced in your `terraform.tfvars`:
```hcl
argocd_secrets = {
  admin_pw             = "your-admin-password"
  ssh_private_key_path = "~/.ssh/argocd_ed25519"  # Path to the private key you just generated
}
```

4. Update your Git repository URLs in the ArgoCD configuration to use SSH format:
   - Change from: `https://github.com/user/repo.git`
   - Change to: `git@github.com:user/repo.git`

## Deployment Instructions

1. Clone this repository
2. Create a `terraform.tfvars` file with your specific configurations
3. **Complete the SSH key setup above** (required for ArgoCD)
4. Initialize Terraform:

```bash
terraform init
```

5. Plan K3s before installing other modules:
```bash
sudo terraform plan -target=module.k3s
```

6. Install K3s (this step must be completed before the rest of the Terraform modules will work):
```bash
sudo terraform apply -target=module.k3s
```

7. Plan all other modules:
```bash
terraform plan
```

8. Apply all other modules:
```bash
terraform apply
```

9. Access the deployed services:
   - Rancher UI: https://[your-server-ip]
   - ArgoCD: https://[argocd-ingress-host] (if configured)
   - pgAdmin4: http://[your-server-ip]:port
   - MLflow: http://[your-server-ip]:port
   - Plex: http://[your-server-ip]:32400/web
   - Dagster: http://[your-server-ip]:port (data orchestration UI)
   - Rear Diff Service: http://[your-server-ip]:port (API service)

## Module Details

### K3s Module

The K3s module handles the installation and configuration of a K3s Kubernetes cluster:

- Configures node resources (CPU, memory)
- Sets up networking with Flannel
- Manages kubeconfig generation
- Implements backup routines for etcd

### Rancher Module

Manages the Rancher installation:

- Deploys cert-manager
- Installs Rancher server
- Configures ingress
- Handles host file registration

### ArgoCD Module

Configures GitOps with ArgoCD:

- Installs ArgoCD server with SSH-based Git repository access
- Sets up GitHub Container Registry authentication via consolidated secrets
- Configures application auto-deployment with SSH key authentication
- Implements security settings with consolidated configuration management
- Uses consolidated `argocd_config` and `argocd_secrets` objects for cleaner module interface

### PostgreSQL Module

Manages PostgreSQL database infrastructure:

- Creates dedicated namespace
- Sets up database credentials for dev/staging/prod environments
- Configures pgAdmin4 web interface

### AI/ML Module

Sets up machine learning infrastructure:

- Deploys MLflow tracking server
- Configures database connections
- Sets up MinIO artifact storage
- Manages secrets for authentication

### Media Module

Sets up comprehensive media and data services infrastructure:

- Creates dedicated namespaces (media-dev/media-stg/media-prod)
- **Plex Media Server**: Configures GPU access with NVIDIA runtime for hardware acceleration
- **Dagster Orchestration**: Data pipeline platform with workspace configuration and PostgreSQL backend
- **Rear Diff Service**: Automotive monitoring service with dedicated database connections
- Implements VPN integration for secure external access
- Manages resource quotas for GPU usage across services
- Multi-environment database connectivity for all services

## Customization

To adapt this project for your environment:

1. Review all `variables.tf` files to understand required inputs
2. Create a `terraform.tfvars` file with your specific values
3. Modify specific modules as needed:
   - Adjust resource limits based on your hardware
   - Customize network settings for your environment
   - Configure ingress settings and hostnames

## Troubleshooting

- **K3s Installation Issues**: Ensure you have sufficient permissions and run with sudo
- **Namespace Deletion Issues**: The repository includes handlers for stuck namespace termination
- **Certificate Problems**: Check cert-manager deployment and validate TLS settings
- **Network Connectivity**: Verify interface settings and firewall rules
- **GPU Integration**: Ensure proper NVIDIA drivers are installed on the host

## Notes

- This project is designed for single-node deployment but can be extended
- All Terraform state is managed locally by default and excluded from git
- Sensitive information should be stored in `terraform.tfvars` (gitignored)
- **ArgoCD requires SSH key setup**: Manual SSH key generation and GitHub configuration must be completed before deployment
- ArgoCD uses SSH-based Git authentication (not HTTPS) for enhanced security
- The media module requires GPU drivers pre-installed on the host system for Plex hardware acceleration
- MLflow and Dagster require PostgreSQL databases to be properly initialized
- Dagster orchestration has been integrated into the media module for tighter coupling with media processing workflows
- Each service (Dagster, Rear Diff) maintains separate database credentials for dev/staging/prod environments
- ArgoCD configuration uses consolidated `locals` objects for cleaner module interfaces

## Resource Quota Management

This project implements comprehensive resource quota management to ensure optimal resource allocation across all Kubernetes namespaces. Resource quotas are enforced at the namespace level using Kubernetes ResourceQuota objects.

### Resource Allocation Strategy

The resource allocation is designed for a system with 24 CPU cores and 32GB RAM:

| Component | CPU Request | CPU Limit | Memory Request | Memory Limit | Notes |
|-----------|-------------|-----------|----------------|--------------|-------|
| **System Overhead** | 2.0 | 2.0 | 2.0Gi | 4.0Gi | OS, SSH, monitoring agents |
| **K3s Control Plane** | 3.0 | 3.0 | 3.0Gi | 6.0Gi | K3s server, etcd, kube-system |
| **Rancher (cattle-system)** | 1.0 | 4.0 | 1.0Gi | 4.0Gi | Rancher management UI |
| **ArgoCD** | 1.0 | 4.0 | 1.0Gi | 4.0Gi | GitOps continuous deployment |
| **PostgreSQL** | 1.0 | 4.0 | 1.0Gi | 4.0Gi | Database services |
| **AI/ML** | 1.0 | 4.0 | 1.0Gi | 8.0Gi | MLflow, reel-driver ML services |
| **Media (prod)** | 2.0 | 4.0 | 2.0Gi | 8.0Gi | Plex, Dagster, ATD production |
| **Media (stg)** | 1.0 | 2.0 | 1.0Gi | 4.0Gi | Staging media services |
| **Media (dev)** | 1.0 | 2.0 | 1.0Gi | 4.0Gi | Development media services |
| **Observability** | 1.0 | 2.0 | 1.0Gi | 4.0Gi | Prometheus, Grafana, Loki |
| **Experiments** | 1.0 | 2.0 | 1.0Gi | 4.0Gi | Research and development |
| **Cert-Manager** | 0.5 | 1.0 | 0.5Gi | 2.0Gi | Certificate management |
| **Unallocated Buffer** | 8.5 | - | 6.5Gi | - | Reserved for system flexibility |

### Resource Quota Configuration

Resource quotas are configured using a consistent pattern across all modules:

```hcl
# terraform.tfvars example
ai_ml_config = {
  resource_quota = {
    cpu_request    = "1"
    cpu_limit      = "4"
    memory_request = "1Gi"
    memory_limit   = "8Gi"
  }
}
```

### Checking Resource Quota Usage

To monitor resource quota usage across all namespaces:

```bash
# Check all resource quotas
kubectl get resourcequota --all-namespaces

# Check specific namespace usage
kubectl describe resourcequota -n ai-ml

# View current resource consumption
kubectl top nodes
kubectl top pods --all-namespaces
```

### Modifying Resource Quotas

To modify resource quotas:

1. Update the appropriate `*_config.resource_quota` values in `terraform.tfvars`
2. Run `terraform plan` to review changes
3. Apply changes with `terraform apply`
4. ResourceQuota changes take effect immediately

### K3s System Resource Reservations

The K3s cluster is configured with system and kubelet resource reservations:

```hcl
k3s_config = {
  resource_quota = {
    system_reserved_cpu = "2"
    system_reserved_memory = "2Gi"
    kube_reserved_cpu = "2"
    kube_reserved_memory = "2Gi"
  }
}
```

These reservations ensure system stability by preventing Kubernetes workloads from consuming all available resources.

### Resource Quota Enforcement

- **CPU Requests**: Guaranteed CPU allocation (enforced by CFS scheduler)
- **CPU Limits**: Maximum CPU usage (burstable up to limit)
- **Memory Requests**: Guaranteed memory allocation
- **Memory Limits**: Hard memory limit (OOMKilled if exceeded)

ResourceQuotas prevent namespace-level resource consumption from exceeding defined limits, ensuring fair resource distribution across all services.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

[MIT License](LICENSE)