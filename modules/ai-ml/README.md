# AI/ML Module

This module deploys AI/ML infrastructure including MLflow experiment tracking and model management.

## Hostpath Requirements

### MLflow Experiment Tracking

The MLflow service requires dedicated directories for logs and packages storage across all environments.

#### Directory Structure
```
/d/k8s/volumes/mlflow/
├── dev/
│   ├── logs/
│   └── packages/
├── stg/
│   ├── logs/
│   └── packages/
└── prod/
    ├── logs/
    └── packages/
```

#### Required Permissions

Create directories and set permissions for all environments:

```bash
# Create directory structure
sudo mkdir -p /d/k8s/volumes/mlflow/{dev,stg,prod}/{logs,packages}

# Set ownership (all MLflow instances use 1000:1000)
sudo chown -R 1000:1000 /d/k8s/volumes/mlflow/{dev,stg,prod}/{logs,packages}

# Set permissions
sudo chmod 755 /d/k8s/volumes/mlflow/{dev,stg,prod}/{logs,packages}
```

#### Configuration Variables

The following variables are configured in your `terraform.tfvars`:

```hcl
mlflow_vars = {
  uid = "1000"
  gid = "1000"
  artifact_store = {
    bucket_name = "mlflow-artifacts"
  }
  path = {
    root = "/d/k8s/volumes/mlflow/"
    directories = {
      logs = "logs",
      packages = "packages"
    }
  }
  pgsql = {
    database = "mlflow"
  }
  prod = {
    port_external = "30500"
  }
  stg = {
    port_external = "30501"
  }
  dev = {
    port_external = "30502"
  }
}

mlflow_secrets = {
  prod = {
    username = "admin"
    password = "your-secure-password"
    pgsql = {
      username = "mlflow_user"
      password = "your-secure-db-password"
    }
  }
  stg = {
    username = "admin"
    password = "your-secure-password"
    pgsql = {
      username = "mlflow_user"
      password = "your-secure-db-password"
    }
  }
  dev = {
    username = "admin"
    password = "your-secure-password"
    pgsql = {
      username = "mlflow_user"
      password = "your-secure-db-password"
    }
  }
}
```

## Kubernetes Resources Created

### ConfigMaps
- `mlflow-config-dev` - Non-sensitive MLflow dev configuration
- `mlflow-config-stg` - Non-sensitive MLflow stg configuration
- `mlflow-config-prod` - Non-sensitive MLflow prod configuration

### Secrets
- `mlflow-secrets-dev` - MLflow dev access credentials and database connection
- `mlflow-secrets-stg` - MLflow stg access credentials and database connection
- `mlflow-secrets-prod` - MLflow prod access credentials and database connection
- `github-registry` - GitHub Container Registry authentication

## Important Notes

1. **Environment Isolation**: Each environment (dev/stg/prod) uses separate directories and database connections
2. **Permissions**: The hostPath directories must be owned by 1000:1000 before deployment
3. **Storage**: MLflow directories should be on persistent storage with adequate space for logs and model packages
4. **Security**: Use strong, unique passwords for each environment
5. **Database**: MLflow requires PostgreSQL database connections (configured via pgsql module)
6. **Artifacts**: MLflow uses MinIO for artifact storage (configured via pgsql module)

## Pre-deployment Checklist

- [ ] Create all required directories with correct permissions (1000:1000)
- [ ] Verify UID/GID 1000:1000 is available for MLflow processes
- [ ] Configure `terraform.tfvars` with appropriate credentials
- [ ] Ensure sufficient disk space for MLflow logs and packages
- [ ] Verify PostgreSQL databases are configured for MLflow
- [ ] Test directory permissions with UID/GID 1000:1000

## Directory Usage

- **logs/**: MLflow experiment logs and metadata
- **packages/**: MLflow model packages and artifacts (local storage)
- **MinIO**: Remote artifact storage via MinIO service (configured in pgsql module)
- **PostgreSQL**: Experiment metadata and model registry (configured in pgsql module)