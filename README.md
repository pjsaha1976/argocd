# ArgoCD Application CRD Example

This repository contains an example ArgoCD Application Custom Resource Definition (CRD) for deploying applications using GitOps practices.

## Structure

```
argocd/
├── applications/           # ArgoCD Application CRDs
│   └── sample-app.yaml    # Main application definition
├── manifests/             # Kubernetes manifests
│   ├── deployment.yaml    # Application deployment
│   ├── service.yaml       # Service definition
│   └── configmap.yaml     # Configuration
└── README.md             # This file
```

## Application CRD Features

The `sample-app.yaml` includes:

- **Automated Sync**: Automatically syncs changes from the Git repository
- **Self-Healing**: Automatically corrects configuration drift
- **Retry Logic**: Configurable retry mechanism for failed syncs
- **Health Checks**: Monitors application health
- **Namespace Creation**: Automatically creates target namespace if needed

## Usage

### Prerequisites

1. ArgoCD installed in your Kubernetes cluster
2. Access to the ArgoCD namespace
3. Git repository containing your application manifests

### Deployment Steps

1. **Update the Application CRD**:
   - Edit `applications/sample-app.yaml`
   - Update the `spec.source.repoURL` to point to your Git repository
   - Modify `spec.destination.namespace` if needed

2. **Apply the Application CRD**:
   ```bash
   kubectl apply -f applications/sample-app.yaml
   ```

3. **Verify the Application**:
   ```bash
   # Check ArgoCD application status
   kubectl get application -n argocd
   
   # Get detailed application info
   kubectl describe application sample-app -n argocd
   ```

### Configuration Options

#### Source Configuration
- `repoURL`: Git repository URL
- `targetRevision`: Branch, tag, or commit SHA
- `path`: Path to manifests within the repository

#### Sync Policy
- `automated.prune`: Remove resources not in Git
- `automated.selfHeal`: Correct configuration drift
- `syncOptions`: Additional sync behaviors

#### Health Monitoring
- `revisionHistoryLimit`: Number of revisions to keep
- `ignoreDifferences`: Fields to ignore during sync

## Customization

### For Helm Applications
Uncomment and configure the Helm section in the Application CRD:

```yaml
helm:
  valueFiles:
    - values.yaml
  parameters:
    - name: image.tag
      value: "v1.0.0"
```

### For Kustomize Applications
Uncomment and configure the Kustomize section:

```yaml
kustomize:
  namePrefix: prod-
  commonLabels:
    environment: production
```

## Monitoring

Use the ArgoCD CLI or Web UI to monitor your applications:

```bash
# Install ArgoCD CLI
brew install argocd

# Login to ArgoCD
argocd login <argocd-server>

# List applications
argocd app list

# Get application details
argocd app get sample-app

# Sync application manually
argocd app sync sample-app
```

## Troubleshooting

### Common Issues

1. **Application OutOfSync**:
   - Check if the Git repository is accessible
   - Verify the path and targetRevision are correct

2. **Sync Failed**:
   - Check resource permissions
   - Verify namespace exists or CreateNamespace is enabled

3. **Health Degraded**:
   - Check pod logs: `kubectl logs -l app=nginx`
   - Verify resource requirements and limits

### Useful Commands

```bash
# Check ArgoCD application events
kubectl get events -n argocd --field-selector involvedObject.name=sample-app

# Check application logs
kubectl logs -l app=nginx -n default

# Force refresh application
argocd app refresh sample-app

# Hard refresh (ignore cache)
argocd app refresh sample-app --hard
```