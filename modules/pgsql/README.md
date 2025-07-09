# PostgreSQL Module

This module deploys PostgreSQL infrastructure including database instances, Flyway migrations, MinIO object storage, and pgAdmin4 management interface.

## Hostpath Requirements

### MinIO Object Storage

The MinIO service requires a dedicated data directory for object storage across all environments.

#### Directory Structure
```
/d/k8s/volumes/minio/
├── dev/
│   └── data/
├── stg/
│   └── data/
└── prod/
    └── data/
```

#### Required Permissions

Create directories and set permissions for all environments:

```bash
# Create directory structure
sudo mkdir -p /d/k8s/volumes/minio/{dev,stg,prod}/data

# Set ownership (all MinIO instances use 1000:1000)
sudo chown -R 1000:1000 /d/k8s/volumes/minio/{dev,stg,prod}/data

# Set permissions
sudo chmod 755 /d/k8s/volumes/minio/{dev,stg,prod}/data
```

#### Configuration Variables

The following variables are configured in your `terraform.tfvars`:

```hcl
minio_config = {
  uid = "1000"
  gid = "1000"
  path = {
    root = "/d/k8s/volumes/minio/"
    directories = {
      data = "data"
    }
  }
  prod = {
    port_external = "30900"
  }
  stg = {
    port_external = "30901"
  }
  dev = {
    port_external = "30902"
  }
}

minio_secrets = {
  dev = {
    access_key = "dev-access-key"
    secret_key = "dev-secret-key"
  }
  stg = {
    access_key = "stg-access-key"
    secret_key = "stg-secret-key"
  }
  prod = {
    access_key = "prod-access-key"
    secret_key = "prod-secret-key"
  }
}
```

## Kubernetes Resources Created

### ConfigMaps
- `minio-config-dev` - Non-sensitive MinIO dev configuration
- `minio-config-stg` - Non-sensitive MinIO stg configuration  
- `minio-config-prod` - Non-sensitive MinIO prod configuration

### Secrets
- `minio-secrets-dev` - MinIO dev access credentials
- `minio-secrets-stg` - MinIO stg access credentials
- `minio-secrets-prod` - MinIO prod access credentials

## Important Notes

1. **Environment Isolation**: Each environment (dev/stg/prod) uses separate data directories but same UID/GID (1000:1000)
2. **Permissions**: The hostPath directories must be owned by 1000:1000 before deployment
3. **Storage**: MinIO data directories should be on persistent storage with adequate space
4. **Security**: Use strong, unique access keys for each environment
5. **Backup**: Consider backup strategies for the MinIO data directories

## Pre-deployment Checklist

- [ ] Create all required directories with correct permissions (1000:1000)
- [ ] Verify UID/GID 1000:1000 is available for MinIO processes
- [ ] Configure `terraform.tfvars` with appropriate paths and credentials
- [ ] Ensure sufficient disk space for MinIO data storage
- [ ] Test directory permissions with UID/GID 1000:1000