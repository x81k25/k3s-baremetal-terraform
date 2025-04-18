# k3s-baremetal-terraform

A comprehensive Terraform project for deploying and managing a K3s Kubernetes cluster on bare metal servers with integrated Rancher, ArgoCD, and media services.

## Overview

This project contains Terraform configurations to automate the deployment of a full-featured K3s cluster on local bare metal infrastructure. It uses modular design to manage each component independently, including K3s installation, Rancher management, Kubernetes resources, ArgoCD for GitOps, and specialized media services.

## Repository Structure

```
.
├── .terraform           # Terraform working directory (gitignored)
├── modules/
│   ├── argo_cd/         # ArgoCD GitOps deployment
│   ├── k3s/             # K3s cluster installation and configuration
│   ├── kubernetes/      # Core Kubernetes resources
│   ├── rancher/         # Rancher management layer
│   └── media/           # Media services (Plex, etc.)
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
- **Media Services**: Pre-configured media stack with GPU support for services like Plex
- **Namespace Management**: Structured namespace provisioning with proper RBAC
- **Container Registry Integration**: GitHub Container Registry authentication
- **Backup Configuration**: Built-in etcd snapshot backups
- **Network Customization**: Flexible network configuration options

## Dependancies

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
- Version
- Repository access
- Resource limits
- Authentication settings

### Media Services
- Plex claim token
- GPU resource allocation

## Deployment Instructions

1. Clone this repository
2. Create a `terraform.tfvars` file with your specific configurations
3. Initialize Terraform:

```bash
terraform init
```

4. plan k3s before installing other modules
```bash
sudo terraform plan -target=module.k3
```

5. install k3s
```bash
sudo terraform apply -target=module.k3s
```

6. plan all other modules

```bash
terraform plan
```

7. apply all other modules

```bash
terraform apply
```

8. Access the deployed services:
   - Rancher UI: https://[your-server-ip]
   - ArgoCD: https://[argocd-ingress-host] (if configured)

## Module Details

### K3s Module

The K3s module handles the installation and configuration of a K3s Kubernetes cluster:

- Configures node resources (CPU, memory)
- Sets up networking with Flannel
- Configures storage
- Implements backup routines for etcd
- Manages kubeconfig generation

### Kubernetes Module

Handles core Kubernetes resources:

- Creates namespaces
- Configures GHCR registry access
- Sets up database namespaces

### Rancher Module

Manages the Rancher installation:

- Deploys cert-manager
- Installs Rancher server
- Configures ingress
- Handles host file registration

### ArgoCD Module

Configures GitOps with ArgoCD:

- Installs ArgoCD server
- Sets up repository access
- Configures application auto-deployment
- Implements security settings

### Media Module

Sets up media services infrastructure:

- Creates dedicated namespaces (dev/staging/prod)
- Configures GPU access
- Sets up Plex configuration
- Implements resource quotas

## Customization

To adapt this project for your environment:

1. Review all `variables.tf` files to understand required inputs
2. Create a `terraform.tfvars` file with your specific values
3. Modify specific modules as needed:
   - Adjust resource limits based on your hardware
   - Customize network settings for your environment
   - Configure ingress settings and hostnames

## Troubleshooting

- **Namespace Deletion Issues**: The repository includes handlers for stuck namespace termination
- **Certificate Problems**: Check cert-manager deployment and validate TLS settings
- **Network Connectivity**: Verify interface settings and firewall rules
- **GPU Integration**: Ensure proper NVIDIA drivers are installed on the host

## Notes

- This project is designed for single-node deployment but can be extended
- All Terraform state is managed locally by default and excluded from git
- Sensitive information should be stored in `terraform.tfvars` (gitignored)
- The media module requires GPU drivers pre-installed on the host system

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

[MIT License](LICENSE)