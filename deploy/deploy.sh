#!/bin/bash

# OpenClaw Azure Deployment Script
# Enhanced version: Uses parameters.json + creates timestamped resource groups
# Usage: ./deploy/deploy.sh [OPTIONS] (from repo root)
#    or: ./deploy.sh [OPTIONS] (from deploy/ directory)

set -e

# Determine script directory and set paths accordingly
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"  # Always run from deploy/ directory

# Default values (can be overridden by CLI args or parameters.json)
LOCATION=""
RESOURCE_GROUP=""
APP_NAME=""
CONTAINER_CPU=""
CONTAINER_MEMORY=""
LOG_RETENTION=""
PARAMETERS_FILE="parameters.json"
CREATE_NEW_GROUP=true
SKIP_CONFIRM=false

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Helper functions
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# IP detection function
detect_public_ip() {
    local ip
    ip=$(curl -s --max-time 5 https://api.ipify.org 2>/dev/null)
    if [ -z "$ip" ]; then
        ip=$(curl -s --max-time 5 https://checkip.amazonaws.com 2>/dev/null | tr -d '[:space:]')
    fi
    echo "$ip"
}

show_usage() {
    cat << EOF
OpenClaw Azure Deployment Script

Usage:
  $0 [OPTIONS]

Description:
  Deploys OpenClaw to Azure Container Apps using parameters.json.
  Creates a NEW timestamped resource group by default for clean deployments.

Options:
  --location LOCATION       Override location from parameters.json
  --cpu CPU                Override container CPU allocation
  --memory MEMORY          Override container memory allocation
  --reuse-group NAME       Reuse existing resource group (no timestamp)
  --no-confirm             Skip confirmation prompt
  --help                   Show this help message

Examples:
  # Simple deployment (uses parameters.json)
  $0

  # Override location
  $0 --location eastus

  # Production deployment (reuse same resource group)
  $0 --reuse-group openclaw-prod-rg

  # Quick deployment without confirmation
  $0 --no-confirm

Setup:
  1. Copy parameters.json.example to parameters.json
  2. Edit parameters.json with your tokens
  3. Run: $0

Security:
  - parameters.json is in .gitignore (never commit secrets!)
  - Use parameters.json.example for the repository
  - All secrets are stored in Azure Key Vault after deployment

EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --location)
            LOCATION="$2"
            shift 2
            ;;
        --cpu)
            CONTAINER_CPU="$2"
            shift 2
            ;;
        --memory)
            CONTAINER_MEMORY="$2"
            shift 2
            ;;
        --reuse-group)
            RESOURCE_GROUP="$2"
            CREATE_NEW_GROUP=false
            shift 2
            ;;
        --no-confirm)
            SKIP_CONFIRM=true
            shift
            ;;
        --help)
            show_usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            echo ""
            show_usage
            exit 1
            ;;
    esac
done

# Check if parameters.json exists
if [ ! -f "$PARAMETERS_FILE" ]; then
    print_error "parameters.json not found!"
    echo ""
    echo "To set up:"
    echo "  1. cp parameters.json.example parameters.json"
    echo "  2. Edit parameters.json with your tokens"
    echo "  3. Run: $0"
    echo ""
    exit 1
fi

# Check Azure CLI
if ! command -v az &> /dev/null; then
    print_error "Azure CLI is not installed."
    echo "Install from: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
fi

# Check if logged in
print_status "Checking Azure CLI login status..."
if ! az account show &> /dev/null; then
    print_error "Not logged in to Azure CLI."
    echo "Run: az login"
    exit 1
fi

# Get subscription info
SUBSCRIPTION=$(az account show --query "name" -o tsv)
SUBSCRIPTION_ID=$(az account show --query "id" -o tsv)

# Read values from parameters.json (only if not overridden by CLI)
if [ -z "$APP_NAME" ]; then
    APP_NAME=$(jq -r '.parameters.appName.value' "$PARAMETERS_FILE")
fi

if [ -z "$LOCATION" ]; then
    LOCATION=$(jq -r '.parameters.location.value' "$PARAMETERS_FILE")
fi

if [ -z "$CONTAINER_CPU" ]; then
    CONTAINER_CPU=$(jq -r '.parameters.containerCpu.value' "$PARAMETERS_FILE")
fi

if [ -z "$CONTAINER_MEMORY" ]; then
    CONTAINER_MEMORY=$(jq -r '.parameters.containerMemory.value' "$PARAMETERS_FILE")
fi

if [ -z "$LOG_RETENTION" ]; then
    LOG_RETENTION=$(jq -r '.parameters.logRetentionDays.value' "$PARAMETERS_FILE")
fi

# Generate resource group name if needed
if [ "$CREATE_NEW_GROUP" = true ]; then
    TIMESTAMP=$(date +%Y%m%d-%H%M%S)
    RESOURCE_GROUP="openclaw-${APP_NAME}-${TIMESTAMP}-rg"
fi

# Generate deployment name
DEPLOYMENT_NAME="openclaw-deploy-$(date +%s)"

# Display deployment info
echo ""
print_header "🚀 OpenClaw Deployment"
echo ""
echo -e "${BLUE}Subscription:${NC}      $SUBSCRIPTION"
echo -e "${BLUE}Resource Group:${NC}    $RESOURCE_GROUP"
echo -e "${BLUE}Location:${NC}         $LOCATION"
echo -e "${BLUE}App Name:${NC}         $APP_NAME"
echo -e "${BLUE}Container CPU:${NC}    $CONTAINER_CPU"
echo -e "${BLUE}Container Memory:${NC} $CONTAINER_MEMORY"
echo -e "${BLUE}Log Retention:${NC}    $LOG_RETENTION days"
echo ""

# Detect user's public IP for security restrictions
echo ""
print_status "🔐 Detecting your public IP address for access control..."
USER_IP=$(detect_public_ip)

if [ -z "$USER_IP" ]; then
    print_error "Could not auto-detect your public IP"
    print_warning "For security, at least one IP address is REQUIRED"
    echo ""
    echo "To find your IP address, visit: https://api.ipify.org"
    echo ""

    # Keep prompting until user provides an IP
    while [ -z "$USER_IP" ]; do
        read -p "Enter your public IP address (required): " MANUAL_IP
        if [ -n "$MANUAL_IP" ]; then
            USER_IP="$MANUAL_IP"
            ALLOWED_IPS="[\"$USER_IP/32\"]"
            print_success "Using IP: $USER_IP"
        else
            print_error "IP address cannot be empty. Deployment requires at least one IP for security."
            echo ""
        fi
    done
else
    ALLOWED_IPS="[\"$USER_IP/32\"]"
    print_success "Detected your public IP: $USER_IP"
    echo -e "${BLUE}Security:${NC}          Only this IP can access Control UI"
fi

echo ""

if [ "$CREATE_NEW_GROUP" = true ]; then
    print_status "Will create NEW resource group (clean deployment)"
else
    print_warning "Will reuse existing resource group: $RESOURCE_GROUP"
fi

# Confirmation prompt
if [ "$SKIP_CONFIRM" = false ]; then
    echo ""
    read -p "Continue with deployment? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Deployment cancelled."
        exit 0
    fi
fi

# Create resource group
echo ""
print_status "Creating resource group: $RESOURCE_GROUP"
az group create \
    --name "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --output none

print_success "Resource group created"

# Deploy ARM template
echo ""
print_status "Deploying ARM template (this takes ~5-7 minutes)..."
echo "Press Ctrl+C to cancel"
echo ""

START_TIME=$(date +%s)

az deployment group create \
    --resource-group "$RESOURCE_GROUP" \
    --name "$DEPLOYMENT_NAME" \
    --template-file azuredeploy.json \
    --parameters @"$PARAMETERS_FILE" \
    --parameters allowedIpAddresses="$ALLOWED_IPS" \
    --output table

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

# Get deployment outputs
echo ""
print_success "Deployment complete in ${DURATION}s!"

CONTAINER_APP_URL=$(az deployment group show \
    --resource-group "$RESOURCE_GROUP" \
    --name "$DEPLOYMENT_NAME" \
    --query "properties.outputs.containerAppUrl.value" \
    -o tsv)

GATEWAY_TOKEN=$(az deployment group show \
    --resource-group "$RESOURCE_GROUP" \
    --name "$DEPLOYMENT_NAME" \
    --query "properties.outputs.gatewayToken.value" \
    -o tsv 2>/dev/null || echo "N/A")

KEY_VAULT=$(az deployment group show \
    --resource-group "$RESOURCE_GROUP" \
    --name "$DEPLOYMENT_NAME" \
    --query "properties.outputs.keyVaultName.value" \
    -o tsv 2>/dev/null || echo "N/A")

# Get container app name from resource group
APP_NAME_OUTPUT=$(az containerapp list \
    --resource-group "$RESOURCE_GROUP" \
    --query "[0].name" \
    -o tsv 2>/dev/null || echo "${APP_NAME}-app")

# Display success info
echo ""
print_header "🎉 Deployment Summary"
echo ""
echo -e "${BLUE}Resource Group:${NC}    $RESOURCE_GROUP"
echo -e "${BLUE}Container App:${NC}     $APP_NAME_OUTPUT"
echo -e "${BLUE}URL:${NC}              $CONTAINER_APP_URL"
if [ "$KEY_VAULT" != "N/A" ]; then
    echo -e "${BLUE}Key Vault:${NC}         $KEY_VAULT"
fi
echo ""

# Display IP restriction info
print_header "🔐 Security Configuration"
echo ""
echo -e "${GREEN}✅ Only your IP ($USER_IP) can access the Control UI${NC}"
echo ""
echo -e "${YELLOW}📍 IP Changed? Add new IP via:${NC}"
echo ""
echo -e "${BLUE}Option 1 - Azure Portal (easiest):${NC}"
echo "  1. Portal → Container Apps → $APP_NAME_OUTPUT"
echo "  2. Ingress → IP Security Restrictions → Add"
echo "  3. Enter: Name=\"NewIP\", IP=\"YOUR_NEW_IP/32\", Action=Allow"
echo "  4. Save"
echo ""
echo -e "${BLUE}Option 2 - Azure CLI (fast):${NC}"
echo "  az containerapp ingress access-restriction set \\"
echo "    --name $APP_NAME_OUTPUT \\"
echo "    --resource-group $RESOURCE_GROUP \\"
echo "    --rule-name \"AllowNewIP\" \\"
echo "    --ip-address \"YOUR_NEW_IP/32\" \\"
echo "    --action Allow"
echo ""
echo -e "${BLUE}Option 3 - Quick update (auto-detect current IP):${NC}"
echo "  az containerapp update \\"
echo "    --name $APP_NAME_OUTPUT \\"
echo "    --resource-group $RESOURCE_GROUP \\"
echo "    --set properties.configuration.ingress.ipSecurityRestrictions=\"[{\\\"name\\\":\\\"CurrentIP\\\",\\\"ipAddressRange\\\":\\\"\$(curl -s https://api.ipify.org)/32\\\",\\\"action\\\":\\\"Allow\\\"}]\""
echo ""
echo -e "${GREEN}🔒 Defense-in-depth: Both gateway token AND IP restriction required.${NC}"
echo ""

if [ "$GATEWAY_TOKEN" != "N/A" ] && [ -n "$GATEWAY_TOKEN" ]; then
    print_header "🔑 Gateway Access Token"
    echo ""
    echo -e "${GREEN}$GATEWAY_TOKEN${NC}"
    echo ""
    echo "Use this token to access the OpenClaw Control UI"
    echo ""
fi
print_header "📝 Quick Commands"
echo ""
echo -e "${YELLOW}# View live logs:${NC}"
echo "az containerapp logs show --name $APP_NAME_OUTPUT --resource-group $RESOURCE_GROUP --follow"
echo ""
echo -e "${YELLOW}# Check health:${NC}"
echo "curl $CONTAINER_APP_URL"
echo ""
echo -e "${YELLOW}# Delete this deployment:${NC}"
echo "az group delete --name $RESOURCE_GROUP --yes --no-wait"
echo ""
print_success "OpenClaw is ready! 🤖"
