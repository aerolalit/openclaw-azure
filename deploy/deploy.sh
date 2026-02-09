#!/bin/bash

# OpenClaw Azure VM Deployment Script
# VM-based deployment with persistent filesystem for package installation
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
VM_SIZE="Standard_B2s"
ADMIN_USERNAME="azureuser"
ADMIN_PASSWORD=""
ENABLE_AUTO_SHUTDOWN="false"
STORAGE_SHARE_QUOTA=""
BACKUP_RETENTION_DAYS=""
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

# Generate random password
generate_password() {
    openssl rand -base64 24 | tr -d "=+/" | cut -c1-20
}

show_usage() {
    cat << EOF
OpenClaw Azure VM Deployment Script

Usage:
  $0 [OPTIONS]

Description:
  Deploys OpenClaw to an Azure VM with persistent filesystem.
  Best for low-tech users who need to install packages dynamically via chat.
  Creates a NEW timestamped resource group by default for clean deployments.

Options:
  --location LOCATION       Override location from parameters.json
  --vm-size SIZE           VM size (B1s, B2s, B2ms). Default: B2s
  --admin-username NAME    VM admin username. Default: azureuser
  --admin-password PASS    VM admin password (min 12 chars). Auto-generated if not provided.
  --auto-shutdown          Enable automatic VM shutdown at 11 PM UTC
  --reuse-group NAME       Reuse existing resource group (no timestamp)
  --no-confirm             Skip confirmation prompt
  --help                   Show this help message

Examples:
  # Simple deployment (uses parameters.json)
  $0

  # Override location and VM size
  $0 --location eastus --vm-size Standard_B2ms

  # Production deployment (reuse same resource group)
  $0 --reuse-group openclaw-prod-rg

  # Development with auto-shutdown
  $0 --auto-shutdown

  # Quick deployment without confirmation
  $0 --no-confirm

Setup:
  1. Copy parameters.json.example to parameters.json
  2. Edit parameters.json with your tokens
  3. Run: $0

Security:
  - parameters.json is in .gitignore (never commit secrets!)
  - Secrets are stored directly on VM (simple for non-tech users)
  - IP restrictions via Network Security Group
  - SSH disabled by default (Serial Console for emergency access)
  - Daily VM backups preserve installed packages

VM Sizes:
  - Standard_B1s:  1 vCPU, 1 GB RAM (~$10/mo)  - Budget
  - Standard_B2s:  2 vCPU, 4 GB RAM (~$40/mo)  - Recommended
  - Standard_B2ms: 2 vCPU, 8 GB RAM (~$80/mo)  - Performance

EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --location)
            LOCATION="$2"
            shift 2
            ;;
        --vm-size)
            VM_SIZE="$2"
            shift 2
            ;;
        --admin-username)
            ADMIN_USERNAME="$2"
            shift 2
            ;;
        --admin-password)
            ADMIN_PASSWORD="$2"
            shift 2
            ;;
        --auto-shutdown)
            ENABLE_AUTO_SHUTDOWN="true"
            shift
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

# Check jq
if ! command -v jq &> /dev/null; then
    print_error "jq is not installed."
    echo "Install jq to parse JSON files"
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

if [ -z "$STORAGE_SHARE_QUOTA" ]; then
    STORAGE_SHARE_QUOTA=$(jq -r '.parameters.storageShareQuota.value // 100' "$PARAMETERS_FILE")
fi

if [ -z "$BACKUP_RETENTION_DAYS" ]; then
    BACKUP_RETENTION_DAYS=$(jq -r '.parameters.backupRetentionDays.value // 7' "$PARAMETERS_FILE")
fi

# Generate admin password if not provided
if [ -z "$ADMIN_PASSWORD" ]; then
    ADMIN_PASSWORD=$(generate_password)
    print_warning "Auto-generated admin password (save this!):"
    echo -e "${GREEN}$ADMIN_PASSWORD${NC}"
    echo ""
fi

# Generate resource group name if needed
if [ "$CREATE_NEW_GROUP" = true ]; then
    TIMESTAMP=$(date +%Y%m%d-%H%M%S)
    RESOURCE_GROUP="openclaw-${APP_NAME}-vm-${TIMESTAMP}-rg"
fi

# Generate deployment name
DEPLOYMENT_NAME="openclaw-vm-deploy-$(date +%s)"

# Display deployment info
echo ""
print_header "🚀 OpenClaw VM Deployment"
echo ""
echo -e "${BLUE}Subscription:${NC}         $SUBSCRIPTION"
echo -e "${BLUE}Resource Group:${NC}       $RESOURCE_GROUP"
echo -e "${BLUE}Location:${NC}            $LOCATION"
echo -e "${BLUE}App Name:${NC}            $APP_NAME"
echo -e "${BLUE}VM Size:${NC}             $VM_SIZE"
echo -e "${BLUE}Admin Username:${NC}      $ADMIN_USERNAME"
echo -e "${BLUE}Auto-Shutdown:${NC}       $ENABLE_AUTO_SHUTDOWN"
echo -e "${BLUE}Storage Quota:${NC}       ${STORAGE_SHARE_QUOTA} GB"
echo -e "${BLUE}Backup Retention:${NC}    $BACKUP_RETENTION_DAYS days"
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
            ALLOWED_IPS="$USER_IP"
            print_success "Using IP: $USER_IP"
        else
            print_error "IP address cannot be empty. Deployment requires at least one IP for security."
            echo ""
        fi
    done
else
    ALLOWED_IPS="$USER_IP"
    print_success "Detected your public IP: $USER_IP"
    echo -e "${BLUE}Security:${NC}            Only this IP can access VM (HTTPS + IP restriction)"
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

# Create filtered parameters file (remove unsupported params)
print_status "Preparing VM parameters..."
VM_PARAMS_FILE=$(mktemp /tmp/openclaw-vm-params.XXXXXX.json)
trap "rm -f $VM_PARAMS_FILE" EXIT

# Extract only parameters that exist in the VM template
jq '{
  "$schema": ."$schema",
  "contentVersion": .contentVersion,
  "parameters": (.parameters | with_entries(select(.key | IN(
    "location", "appName",
    "anthropicApiKey", "discordBotToken", "telegramBotToken",
    "slackBotToken", "whatsappToken", "openaiApiKey", "groqApiKey",
    "cohereApiKey", "braveSearchApiKey", "elevenlabsApiKey",
    "githubToken", "notionApiKey", "gatewayToken", "webhookSecret",
    "storageShareQuota", "backupRetentionDays"
  ))))
}' "$PARAMETERS_FILE" > "$VM_PARAMS_FILE"

print_success "Parameters prepared"

# Deploy ARM template
echo ""
print_status "Deploying Azure VM (this takes ~10-15 minutes)..."
echo "Press Ctrl+C to cancel"
echo ""

START_TIME=$(date +%s)

az deployment group create \
    --resource-group "$RESOURCE_GROUP" \
    --name "$DEPLOYMENT_NAME" \
    --template-file azuredeploy.json \
    --parameters @"$VM_PARAMS_FILE" \
    --parameters allowedIpAddresses="$ALLOWED_IPS" \
    --parameters vmSize="$VM_SIZE" \
    --parameters adminUsername="$ADMIN_USERNAME" \
    --parameters adminPassword="$ADMIN_PASSWORD" \
    --parameters enableAutoShutdown="$ENABLE_AUTO_SHUTDOWN" \
    --output table

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

# Get deployment outputs
echo ""
print_success "Deployment complete in ${DURATION}s!"

VM_NAME=$(az deployment group show \
    --resource-group "$RESOURCE_GROUP" \
    --name "$DEPLOYMENT_NAME" \
    --query "properties.outputs.vmName.value" \
    -o tsv)

VM_PUBLIC_IP=$(az deployment group show \
    --resource-group "$RESOURCE_GROUP" \
    --name "$DEPLOYMENT_NAME" \
    --query "properties.outputs.vmPublicIp.value" \
    -o tsv)

VM_DNS_NAME=$(az deployment group show \
    --resource-group "$RESOURCE_GROUP" \
    --name "$DEPLOYMENT_NAME" \
    --query "properties.outputs.vmDnsName.value" \
    -o tsv)

CONTROL_UI_URL=$(az deployment group show \
    --resource-group "$RESOURCE_GROUP" \
    --name "$DEPLOYMENT_NAME" \
    --query "properties.outputs.controlUiUrl.value" \
    -o tsv 2>/dev/null || echo "https://$VM_DNS_NAME")

GATEWAY_TOKEN=$(az deployment group show \
    --resource-group "$RESOURCE_GROUP" \
    --name "$DEPLOYMENT_NAME" \
    --query "properties.outputs.gatewayToken.value" \
    -o tsv 2>/dev/null || echo "N/A")

STORAGE_ACCOUNT=$(az deployment group show \
    --resource-group "$RESOURCE_GROUP" \
    --name "$DEPLOYMENT_NAME" \
    --query "properties.outputs.storageAccountName.value" \
    -o tsv 2>/dev/null || echo "N/A")

RECOVERY_VAULT=$(az deployment group show \
    --resource-group "$RESOURCE_GROUP" \
    --name "$DEPLOYMENT_NAME" \
    --query "properties.outputs.recoveryVaultName.value" \
    -o tsv 2>/dev/null || echo "N/A")

# Post-deployment: Mount Azure Files on VM and restart container
echo ""
print_status "Configuring Azure Files mount on VM..."

STORAGE_KEY=$(az storage account keys list \
    --resource-group "$RESOURCE_GROUP" \
    --account-name "$STORAGE_ACCOUNT" \
    --query "[0].value" \
    -o tsv)

# Create script to mount Azure Files and add to fstab for persistence
MOUNT_SCRIPT="#!/bin/bash
set -e

# Install cifs-utils if not already installed
apt-get install -y cifs-utils 2>/dev/null || true

# Create mount point
mkdir -p /workspace

# Create credentials file (secure)
cat > /etc/openclaw/azure-files-creds <<CREDEOF
username=${STORAGE_ACCOUNT}
password=${STORAGE_KEY}
CREDEOF
chmod 600 /etc/openclaw/azure-files-creds

# Mount Azure Files
mount -t cifs //${STORAGE_ACCOUNT}.file.core.windows.net/openclaw-data /workspace -o vers=3.0,credentials=/etc/openclaw/azure-files-creds,dir_mode=0777,file_mode=0666,serverino

# Add to fstab for persistence across reboots
grep -q 'openclaw-data' /etc/fstab || echo \"//${STORAGE_ACCOUNT}.file.core.windows.net/openclaw-data /workspace cifs vers=3.0,credentials=/etc/openclaw/azure-files-creds,dir_mode=0777,file_mode=0666,serverino 0 0\" >> /etc/fstab

# Restart Docker container to pick up mounted workspace
docker restart openclaw 2>/dev/null || echo 'Container not ready yet, will use mount on next start'

echo '✅ Azure Files mounted at /workspace and added to fstab'
"

# Run the mount script on VM via Azure CLI
print_status "Running mount script on VM (may take 30-60 seconds)..."
az vm run-command invoke \
    --resource-group "$RESOURCE_GROUP" \
    --name "$VM_NAME" \
    --command-id RunShellScript \
    --scripts "$MOUNT_SCRIPT" \
    --query "value[0].message" \
    -o tsv || print_warning "Could not mount Azure Files automatically. Cloud-init may still be running - try again in 5 minutes."

print_success "Post-deployment configuration complete"

# Display success info
echo ""
print_header "🎉 Deployment Summary"
echo ""
echo -e "${BLUE}Resource Group:${NC}       $RESOURCE_GROUP"
echo -e "${BLUE}VM Name:${NC}              $VM_NAME"
echo -e "${BLUE}Public IP:${NC}            $VM_PUBLIC_IP"
echo -e "${BLUE}DNS Name:${NC}             $VM_DNS_NAME"
echo -e "${BLUE}Control UI URL:${NC}       $CONTROL_UI_URL"
if [ "$STORAGE_ACCOUNT" != "N/A" ]; then
    echo -e "${BLUE}Storage Account:${NC}      $STORAGE_ACCOUNT"
fi
if [ "$RECOVERY_VAULT" != "N/A" ]; then
    echo -e "${BLUE}Recovery Vault:${NC}       $RECOVERY_VAULT"
fi
echo ""

# Display IP restriction info
print_header "🔐 Security Configuration"
echo ""
echo -e "${GREEN}✅ HTTPS enabled (automatic Let's Encrypt certificate via Caddy)${NC}"
echo -e "${GREEN}✅ Only your IP ($USER_IP) can access the VM${NC}"
echo -e "${GREEN}✅ SSH is disabled (use Serial Console for emergency access)${NC}"
echo -e "${GREEN}✅ Secrets stored on VM at /etc/openclaw/.env${NC}"
echo -e "${GREEN}✅ Daily VM backups enabled (preserves installed packages)${NC}"
echo ""
echo -e "${YELLOW}📍 IP Changed? Add new IP via:${NC}"
echo ""
echo -e "${BLUE}Option 1 - Azure Portal (easiest):${NC}"
echo "  1. Portal → Network Security Groups → ${APP_NAME}-nsg"
echo "  2. Inbound security rules → Add"
echo "  3. Enter: Source=IP Address, Source IP=\"YOUR_NEW_IP/32\", Port=443"
echo "  4. Save"
echo ""
echo -e "${BLUE}Option 2 - Azure CLI (fast):${NC}"
echo "  az network nsg rule create \\"
echo "    --resource-group $RESOURCE_GROUP \\"
echo "    --nsg-name ${APP_NAME}-nsg \\"
echo "    --name AllowNewIP \\"
echo "    --priority 1100 \\"
echo "    --source-address-prefixes YOUR_NEW_IP/32 \\"
echo "    --destination-port-ranges 443 \\"
echo "    --protocol Tcp --access Allow"
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
echo -e "${YELLOW}# Check VM cloud-init status (OpenClaw installation):${NC}"
echo "az vm run-command invoke \\"
echo "  --resource-group $RESOURCE_GROUP \\"
echo "  --name $VM_NAME \\"
echo "  --command-id RunShellScript \\"
echo "  --scripts 'cloud-init status --wait'"
echo ""
echo -e "${YELLOW}# Check OpenClaw service status:${NC}"
echo "az vm run-command invoke \\"
echo "  --resource-group $RESOURCE_GROUP \\"
echo "  --name $VM_NAME \\"
echo "  --command-id RunShellScript \\"
echo "  --scripts 'systemctl status openclaw'"
echo ""
echo -e "${YELLOW}# View OpenClaw logs:${NC}"
echo "az vm run-command invoke \\"
echo "  --resource-group $RESOURCE_GROUP \\"
echo "  --name $VM_NAME \\"
echo "  --command-id RunShellScript \\"
echo "  --scripts 'journalctl -u openclaw -n 50 --no-pager'"
echo ""
echo -e "${YELLOW}# Access Serial Console (emergency):${NC}"
echo "Azure Portal → Virtual Machines → $VM_NAME → Serial Console"
echo ""
echo -e "${YELLOW}# Delete this deployment:${NC}"
echo "az group delete --name $RESOURCE_GROUP --yes --no-wait"
echo ""

print_header "⏱️  Installation in Progress"
echo ""
echo -e "${YELLOW}OpenClaw is being installed via cloud-init (takes 5-10 minutes).${NC}"
echo ""
echo "The VM is running, but OpenClaw may not be ready yet."
echo "Check installation status with the cloud-init command above."
echo ""
echo -e "${CYAN}Once installation completes:${NC}"
echo "  1. Open Control UI: $CONTROL_UI_URL"
echo "  2. Enter Gateway Token"
echo "  3. Configure your bot channels"
echo ""

print_success "OpenClaw VM deployment complete! 🤖"

# Save admin credentials to a file (for user reference)
CREDS_FILE="${RESOURCE_GROUP}-credentials.txt"
cat > "$CREDS_FILE" << EOF
OpenClaw VM Credentials
=======================

Resource Group: $RESOURCE_GROUP
VM Name: $VM_NAME
Admin Username: $ADMIN_USERNAME
Admin Password: $ADMIN_PASSWORD

Public IP: $VM_PUBLIC_IP
DNS Name: $VM_DNS_NAME
Control UI: $CONTROL_UI_URL
Gateway Token: $GATEWAY_TOKEN

⚠️  KEEP THIS FILE SECURE! Delete after saving credentials elsewhere.

Access:
- Serial Console: Azure Portal → Virtual Machines → $VM_NAME → Serial Console
- Logs: Use 'az vm run-command' shown in deployment output

EOF

print_success "Credentials saved to: $CREDS_FILE"
echo -e "${RED}⚠️  IMPORTANT: Save credentials securely and delete this file!${NC}"
echo ""
