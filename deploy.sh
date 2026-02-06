#!/bin/bash

# OpenClaw Azure Deployment Script
# Usage: ./deploy.sh --name "my-openclaw" --discord-token "YOUR_TOKEN" --anthropic-key "YOUR_KEY"

set -e

# Default values
LOCATION="eastus"
RESOURCE_GROUP=""
APP_NAME=""
DISCORD_TOKEN=""
ANTHROPIC_KEY=""
CONTAINER_CPU="1.0"
CONTAINER_MEMORY="2Gi"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
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

# Function to show usage
show_usage() {
    echo "OpenClaw Azure Deployment Script"
    echo ""
    echo "Usage:"
    echo "  $0 --name APP_NAME --discord-token TOKEN --anthropic-key KEY [OPTIONS]"
    echo ""
    echo "Required arguments:"
    echo "  --name NAME              Name for your OpenClaw instance"
    echo "  --discord-token TOKEN    Discord bot token"
    echo "  --anthropic-key KEY      Anthropic Claude API key"
    echo ""
    echo "Optional arguments:"
    echo "  --location LOCATION      Azure region (default: eastus)"
    echo "  --resource-group RG      Resource group name (default: openclaw-NAME-rg)"
    echo "  --cpu CPU               Container CPU (default: 1.0)"
    echo "  --memory MEMORY         Container memory (default: 2Gi)"
    echo "  --help                   Show this help message"
    echo ""
    echo "Example:"
    echo "  $0 --name \"my-openclaw\" --discord-token \"MT...\" --anthropic-key \"sk-ant-...\""
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --name)
            APP_NAME="$2"
            shift 2
            ;;
        --discord-token)
            DISCORD_TOKEN="$2"
            shift 2
            ;;
        --anthropic-key)
            ANTHROPIC_KEY="$2"
            shift 2
            ;;
        --location)
            LOCATION="$2"
            shift 2
            ;;
        --resource-group)
            RESOURCE_GROUP="$2"
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
        --help)
            show_usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Validate required arguments
if [[ -z "$APP_NAME" ]]; then
    print_error "App name is required. Use --name to specify."
    show_usage
    exit 1
fi

if [[ -z "$DISCORD_TOKEN" ]]; then
    print_error "Discord token is required. Use --discord-token to specify."
    show_usage
    exit 1
fi

if [[ -z "$ANTHROPIC_KEY" ]]; then
    print_error "Anthropic API key is required. Use --anthropic-key to specify."
    show_usage
    exit 1
fi

# Set default resource group name if not provided
if [[ -z "$RESOURCE_GROUP" ]]; then
    RESOURCE_GROUP="openclaw-${APP_NAME}-rg"
fi

# Validate app name (alphanumeric only)
if [[ ! "$APP_NAME" =~ ^[a-zA-Z0-9]+$ ]]; then
    print_error "App name must contain only letters and numbers."
    exit 1
fi

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    print_error "Azure CLI is not installed. Please install it first:"
    echo "https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
fi

# Check if logged in to Azure
print_status "Checking Azure CLI login status..."
if ! az account show &> /dev/null; then
    print_error "Not logged in to Azure CLI. Please run 'az login' first."
    exit 1
fi

# Show current subscription
SUBSCRIPTION_NAME=$(az account show --query "name" --output tsv)
SUBSCRIPTION_ID=$(az account show --query "id" --output tsv)
print_status "Using Azure subscription: $SUBSCRIPTION_NAME ($SUBSCRIPTION_ID)"

# Confirm deployment
echo ""
print_warning "About to deploy OpenClaw with the following settings:"
echo "  App Name: $APP_NAME"
echo "  Location: $LOCATION"
echo "  Resource Group: $RESOURCE_GROUP"
echo "  Container CPU: $CONTAINER_CPU"
echo "  Container Memory: $CONTAINER_MEMORY"
echo ""
read -p "Continue with deployment? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_status "Deployment cancelled."
    exit 0
fi

# Create resource group
print_status "Creating resource group: $RESOURCE_GROUP"
if az group create \
    --name "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --output none; then
    print_success "Resource group created successfully."
else
    print_error "Failed to create resource group."
    exit 1
fi

# Deploy the ARM template
print_status "Starting Azure deployment (this may take 5-10 minutes)..."
DEPLOYMENT_NAME="openclaw-deployment-$(date +%s)"

if az deployment group create \
    --resource-group "$RESOURCE_GROUP" \
    --template-file "azuredeploy.json" \
    --name "$DEPLOYMENT_NAME" \
    --parameters \
        appName="$APP_NAME" \
        location="$LOCATION" \
        discordBotToken="$DISCORD_TOKEN" \
        anthropicApiKey="$ANTHROPIC_KEY" \
        containerCpu="$CONTAINER_CPU" \
        containerMemory="$CONTAINER_MEMORY" \
    --output none; then
    print_success "Deployment completed successfully!"
else
    print_error "Deployment failed. Check the Azure portal for details."
    exit 1
fi

# Get deployment outputs
print_status "Retrieving deployment information..."
CONTAINER_APP_URL=$(az deployment group show \
    --resource-group "$RESOURCE_GROUP" \
    --name "$DEPLOYMENT_NAME" \
    --query "properties.outputs.containerAppUrl.value" \
    --output tsv)

KEY_VAULT_NAME=$(az deployment group show \
    --resource-group "$RESOURCE_GROUP" \
    --name "$DEPLOYMENT_NAME" \
    --query "properties.outputs.keyVaultName.value" \
    --output tsv)

STORAGE_ACCOUNT_NAME=$(az deployment group show \
    --resource-group "$RESOURCE_GROUP" \
    --name "$DEPLOYMENT_NAME" \
    --query "properties.outputs.storageAccountName.value" \
    --output tsv)

# Display success information
echo ""
echo "🎉 OpenClaw deployment completed successfully!"
echo ""
echo "📋 Deployment Summary:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "App Name:           $APP_NAME"
echo "Resource Group:     $RESOURCE_GROUP"
echo "Location:           $LOCATION"
echo "Container App URL:  $CONTAINER_APP_URL"
echo "Key Vault:          $KEY_VAULT_NAME"
echo "Storage Account:    $STORAGE_ACCOUNT_NAME"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🚀 Next Steps:"
echo "1. Go to your Discord server"
echo "2. Mention your bot: @YourBotName hello"
echo "3. Your OpenClaw should respond!"
echo ""
echo "📊 Monitor your deployment:"
echo "Azure Portal: https://portal.azure.com/#@/resource/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP"
echo ""
echo "💰 Expected monthly cost: ~\$20-30 (plus Anthropic API usage)"
echo ""
print_success "Happy chatting with your OpenClaw! 🤖"