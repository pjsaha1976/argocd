#!/bin/bash

# ArgoCD Application Deployment Script
# This script helps deploy and manage ArgoCD applications

set -e

NAMESPACE="argocd"
APP_NAME="sample-app"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if ArgoCD is installed
check_argocd() {
    print_status "Checking if ArgoCD is installed..."
    if kubectl get namespace $NAMESPACE >/dev/null 2>&1; then
        print_status "ArgoCD namespace found"
    else
        print_error "ArgoCD namespace not found. Please install ArgoCD first."
        echo "Install ArgoCD with: kubectl create namespace argocd && kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml"
        exit 1
    fi
}

# Function to apply the application
deploy_application() {
    print_status "Deploying ArgoCD application..."
    
    if kubectl apply -f applications/$APP_NAME.yaml; then
        print_status "Application deployed successfully"
    else
        print_error "Failed to deploy application"
        exit 1
    fi
}

# Function to check application status
check_application_status() {
    print_status "Checking application status..."
    
    # Wait a moment for the application to be processed
    sleep 5
    
    # Get application status
    if kubectl get application $APP_NAME -n $NAMESPACE >/dev/null 2>&1; then
        print_status "Application found in ArgoCD"
        
        # Show detailed status
        echo ""
        kubectl get application $APP_NAME -n $NAMESPACE -o wide
        
        echo ""
        print_status "Application health and sync status:"
        kubectl get application $APP_NAME -n $NAMESPACE -o jsonpath='{.status.health.status}' && echo " (Health)"
        kubectl get application $APP_NAME -n $NAMESPACE -o jsonpath='{.status.sync.status}' && echo " (Sync)"
    else
        print_error "Application not found in ArgoCD"
        exit 1
    fi
}

# Function to show application resources
show_resources() {
    print_status "Showing managed resources..."
    echo ""
    
    # Check if resources are deployed
    echo "Deployments:"
    kubectl get deployments -l app=nginx || echo "No deployments found"
    
    echo ""
    echo "Services:"
    kubectl get services -l app=nginx || echo "No services found"
    
    echo ""
    echo "ConfigMaps:"
    kubectl get configmaps -l app=nginx || echo "No configmaps found"
    
    echo ""
    echo "Pods:"
    kubectl get pods -l app=nginx || echo "No pods found"
}

# Function to sync application manually
sync_application() {
    print_status "Manually syncing application..."
    
    # Check if argocd CLI is available
    if command -v argocd >/dev/null 2>&1; then
        # Note: This requires argocd login to be done first
        print_warning "Make sure you're logged in to ArgoCD CLI"
        argocd app sync $APP_NAME || print_warning "Sync via CLI failed, application will auto-sync"
    else
        print_warning "ArgoCD CLI not found. Application will auto-sync based on policy."
        print_status "Install ArgoCD CLI: brew install argocd (macOS) or follow official docs"
    fi
}

# Function to cleanup
cleanup() {
    print_warning "Removing ArgoCD application..."
    kubectl delete -f applications/$APP_NAME.yaml || print_error "Failed to delete application"
}

# Main execution
case "${1:-deploy}" in
    "deploy")
        check_argocd
        deploy_application
        check_application_status
        show_resources
        ;;
    "status")
        check_application_status
        show_resources
        ;;
    "sync")
        sync_application
        ;;
    "cleanup")
        cleanup
        ;;
    "help"|"-h"|"--help")
        echo "Usage: $0 [command]"
        echo ""
        echo "Commands:"
        echo "  deploy   - Deploy the ArgoCD application (default)"
        echo "  status   - Check application and resource status"
        echo "  sync     - Manually sync the application"
        echo "  cleanup  - Remove the application"
        echo "  help     - Show this help message"
        ;;
    *)
        print_error "Unknown command: $1"
        echo "Use '$0 help' for available commands"
        exit 1
        ;;
esac