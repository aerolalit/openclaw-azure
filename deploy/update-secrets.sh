#!/bin/bash

# OpenClaw VM Secrets Update Script
# Updates secrets on an already-deployed OpenClaw VM
# Usage: ./deploy/update-secrets.sh --resource-group <rg-name> [OPTIONS]

set -e

# Default values
RESOURCE_GROUP=""
VM_NAME=""
PARAMETERS_FILE="parameters.json"

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

show_usage() {
    cat << EOF
OpenClaw VM Secrets Update Script

Usage:
  $0 --resource-group <rg-name> [OPTIONS]

Description:
  Updates API keys and bot tokens on an already-deployed OpenClaw VM.
  Reads secrets from parameters.json and updates /etc/openclaw/.env on the VM.
  Restarts OpenClaw service to apply changes.

Options:
  --resource-group NAME    Azure resource group name (required)
  --vm-name NAME           VM name (auto-detected if not provided)
  --parameters FILE        Parameters file (default: parameters.json)
  --help                   Show this help message

Examples:
  # Update secrets from parameters.json
  $0 --resource-group openclaw-mybot-vm-20260209-143022-rg

  # Use custom parameters file
  $0 --resource-group openclaw-prod-rg --parameters parameters-prod.json

  # Specify VM name explicitly
  $0 --resource-group openclaw-prod-rg --vm-name mybot-vm

Workflow:
  1. Edit parameters.json with new secrets
  2. Run this script
  3. Script updates /etc/openclaw/.env on VM
  4. Script restarts OpenClaw service
  5. New secrets take effect immediately

Security:
  - Secrets are transmitted securely via Azure CLI
  - Old secrets are overwritten (not preserved)
  - Service restart ensures secrets are loaded
  - No VM restart required

EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --resource-group)
            RESOURCE_GROUP="$2"
            shift 2
            ;;
        --vm-name)
            VM_NAME="$2"
            shift 2
            ;;
        --parameters)
            PARAMETERS_FILE="$2"
            shift 2
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

# Validate required arguments
if [ -z "$RESOURCE_GROUP" ]; then
    print_error "Resource group name is required"
    echo ""
    show_usage
    exit 1
fi

# Check if parameters.json exists
if [ ! -f "$PARAMETERS_FILE" ]; then
    print_error "$PARAMETERS_FILE not found!"
    echo ""
    echo "To set up:"
    echo "  1. Copy parameters.json.example to $PARAMETERS_FILE"
    echo "  2. Edit $PARAMETERS_FILE with your new secrets"
    echo "  3. Run this script"
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

# Auto-detect VM name if not provided
if [ -z "$VM_NAME" ]; then
    print_status "Auto-detecting VM name..."
    VM_NAME=$(az vm list --resource-group "$RESOURCE_GROUP" --query "[0].name" -o tsv 2>/dev/null)

    if [ -z "$VM_NAME" ] || [ "$VM_NAME" = "null" ]; then
        print_error "Could not find VM in resource group: $RESOURCE_GROUP"
        echo "Specify VM name with --vm-name option"
        exit 1
    fi

    print_success "Found VM: $VM_NAME"
fi

# Verify VM exists
print_status "Verifying VM exists..."
VM_EXISTS=$(az vm show --resource-group "$RESOURCE_GROUP" --name "$VM_NAME" --query "name" -o tsv 2>/dev/null || echo "")

if [ -z "$VM_EXISTS" ]; then
    print_error "VM '$VM_NAME' not found in resource group '$RESOURCE_GROUP'"
    exit 1
fi

print_success "VM verified"

# Read secrets from parameters.json
print_status "Reading secrets from $PARAMETERS_FILE..."

ANTHROPIC_API_KEY=$(jq -r '.parameters.anthropicApiKey.value // ""' "$PARAMETERS_FILE")
DISCORD_BOT_TOKEN=$(jq -r '.parameters.discordBotToken.value // ""' "$PARAMETERS_FILE")
TELEGRAM_BOT_TOKEN=$(jq -r '.parameters.telegramBotToken.value // ""' "$PARAMETERS_FILE")
SLACK_BOT_TOKEN=$(jq -r '.parameters.slackBotToken.value // ""' "$PARAMETERS_FILE")
WHATSAPP_TOKEN=$(jq -r '.parameters.whatsappToken.value // ""' "$PARAMETERS_FILE")
OPENAI_API_KEY=$(jq -r '.parameters.openaiApiKey.value // ""' "$PARAMETERS_FILE")
GROQ_API_KEY=$(jq -r '.parameters.groqApiKey.value // ""' "$PARAMETERS_FILE")
COHERE_API_KEY=$(jq -r '.parameters.cohereApiKey.value // ""' "$PARAMETERS_FILE")
ELEVENLABS_API_KEY=$(jq -r '.parameters.elevenlabsApiKey.value // ""' "$PARAMETERS_FILE")
BRAVE_SEARCH_API_KEY=$(jq -r '.parameters.braveSearchApiKey.value // ""' "$PARAMETERS_FILE")
GITHUB_TOKEN=$(jq -r '.parameters.githubToken.value // ""' "$PARAMETERS_FILE")
NOTION_API_KEY=$(jq -r '.parameters.notionApiKey.value // ""' "$PARAMETERS_FILE")
GATEWAY_TOKEN=$(jq -r '.parameters.gatewayToken.value // ""' "$PARAMETERS_FILE")
WEBHOOK_SECRET=$(jq -r '.parameters.webhookSecret.value // ""' "$PARAMETERS_FILE")

print_success "Secrets loaded from parameters file"

# Display what will be updated
echo ""
print_header "🔄 Secrets Update Summary"
echo ""
echo -e "${BLUE}Resource Group:${NC}     $RESOURCE_GROUP"
echo -e "${BLUE}VM Name:${NC}            $VM_NAME"
echo -e "${BLUE}Parameters File:${NC}    $PARAMETERS_FILE"
echo ""
echo -e "${YELLOW}Secrets to update:${NC}"
echo ""
[ -n "$ANTHROPIC_API_KEY" ] && echo "  ✓ Anthropic API Key"
[ -n "$DISCORD_BOT_TOKEN" ] && echo "  ✓ Discord Bot Token"
[ -n "$TELEGRAM_BOT_TOKEN" ] && echo "  ✓ Telegram Bot Token"
[ -n "$SLACK_BOT_TOKEN" ] && echo "  ✓ Slack Bot Token"
[ -n "$WHATSAPP_TOKEN" ] && echo "  ✓ WhatsApp Token"
[ -n "$OPENAI_API_KEY" ] && echo "  ✓ OpenAI API Key"
[ -n "$GROQ_API_KEY" ] && echo "  ✓ Groq API Key"
[ -n "$COHERE_API_KEY" ] && echo "  ✓ Cohere API Key"
[ -n "$ELEVENLABS_API_KEY" ] && echo "  ✓ ElevenLabs API Key"
[ -n "$BRAVE_SEARCH_API_KEY" ] && echo "  ✓ Brave Search API Key"
[ -n "$GITHUB_TOKEN" ] && echo "  ✓ GitHub Token"
[ -n "$NOTION_API_KEY" ] && echo "  ✓ Notion API Key"
[ -n "$GATEWAY_TOKEN" ] && echo "  ✓ Gateway Token"
[ -n "$WEBHOOK_SECRET" ] && echo "  ✓ Webhook Secret"
echo ""

# Confirmation prompt
read -p "Continue with secrets update? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_status "Update cancelled."
    exit 0
fi

# Create update script for VM
UPDATE_SCRIPT=$(cat << 'SCRIPT_EOF'
#!/bin/bash
set -e

# Backup current .env file
cp /etc/openclaw/.env /etc/openclaw/.env.backup.$(date +%s)

# Update .env file with new secrets
cat > /etc/openclaw/.env << 'ENV_EOF'
# OpenClaw Environment Variables
# Updated: $(date)

DISCORD_BOT_TOKEN=DISCORD_BOT_TOKEN_PLACEHOLDER
TELEGRAM_BOT_TOKEN=TELEGRAM_BOT_TOKEN_PLACEHOLDER
SLACK_BOT_TOKEN=SLACK_BOT_TOKEN_PLACEHOLDER
WHATSAPP_TOKEN=WHATSAPP_TOKEN_PLACEHOLDER
ANTHROPIC_API_KEY=ANTHROPIC_API_KEY_PLACEHOLDER
OPENAI_API_KEY=OPENAI_API_KEY_PLACEHOLDER
GROQ_API_KEY=GROQ_API_KEY_PLACEHOLDER
COHERE_API_KEY=COHERE_API_KEY_PLACEHOLDER
ELEVENLABS_API_KEY=ELEVENLABS_API_KEY_PLACEHOLDER
BRAVE_SEARCH_API_KEY=BRAVE_SEARCH_API_KEY_PLACEHOLDER
GITHUB_TOKEN=GITHUB_TOKEN_PLACEHOLDER
NOTION_API_KEY=NOTION_API_KEY_PLACEHOLDER
OPENCLAW_GATEWAY_TOKEN=GATEWAY_TOKEN_PLACEHOLDER
WEBHOOK_SECRET=WEBHOOK_SECRET_PLACEHOLDER
NODE_ENV=production
OPENCLAW_AUTO_START=gateway
OPENCLAW_GATEWAY_PORT=18789
OPENCLAW_GATEWAY_AUTH_MODE=none
OPENCLAW_GATEWAY_BIND=lan
OPENCLAW_CHANNELS_TELEGRAM_DM_POLICY=trust
HOST=0.0.0.0
ENV_EOF

# Set correct permissions
chmod 600 /etc/openclaw/.env

# Restart OpenClaw service
systemctl restart openclaw

# Wait for service to start
sleep 3

# Check service status
if systemctl is-active --quiet openclaw; then
  echo "✅ OpenClaw service restarted successfully with new secrets"
  systemctl status openclaw --no-pager -l
else
  echo "⚠️  OpenClaw service failed to start. Check logs with: journalctl -u openclaw -n 50"
  exit 1
fi
SCRIPT_EOF
)

# Replace placeholders with actual secrets
UPDATE_SCRIPT="${UPDATE_SCRIPT//DISCORD_BOT_TOKEN_PLACEHOLDER/$DISCORD_BOT_TOKEN}"
UPDATE_SCRIPT="${UPDATE_SCRIPT//TELEGRAM_BOT_TOKEN_PLACEHOLDER/$TELEGRAM_BOT_TOKEN}"
UPDATE_SCRIPT="${UPDATE_SCRIPT//SLACK_BOT_TOKEN_PLACEHOLDER/$SLACK_BOT_TOKEN}"
UPDATE_SCRIPT="${UPDATE_SCRIPT//WHATSAPP_TOKEN_PLACEHOLDER/$WHATSAPP_TOKEN}"
UPDATE_SCRIPT="${UPDATE_SCRIPT//ANTHROPIC_API_KEY_PLACEHOLDER/$ANTHROPIC_API_KEY}"
UPDATE_SCRIPT="${UPDATE_SCRIPT//OPENAI_API_KEY_PLACEHOLDER/$OPENAI_API_KEY}"
UPDATE_SCRIPT="${UPDATE_SCRIPT//GROQ_API_KEY_PLACEHOLDER/$GROQ_API_KEY}"
UPDATE_SCRIPT="${UPDATE_SCRIPT//COHERE_API_KEY_PLACEHOLDER/$COHERE_API_KEY}"
UPDATE_SCRIPT="${UPDATE_SCRIPT//ELEVENLABS_API_KEY_PLACEHOLDER/$ELEVENLABS_API_KEY}"
UPDATE_SCRIPT="${UPDATE_SCRIPT//BRAVE_SEARCH_API_KEY_PLACEHOLDER/$BRAVE_SEARCH_API_KEY}"
UPDATE_SCRIPT="${UPDATE_SCRIPT//GITHUB_TOKEN_PLACEHOLDER/$GITHUB_TOKEN}"
UPDATE_SCRIPT="${UPDATE_SCRIPT//NOTION_API_KEY_PLACEHOLDER/$NOTION_API_KEY}"
UPDATE_SCRIPT="${UPDATE_SCRIPT//GATEWAY_TOKEN_PLACEHOLDER/$GATEWAY_TOKEN}"
UPDATE_SCRIPT="${UPDATE_SCRIPT//WEBHOOK_SECRET_PLACEHOLDER/$WEBHOOK_SECRET}"

# Execute update script on VM
echo ""
print_status "Updating secrets on VM (this may take 10-20 seconds)..."

RESULT=$(echo "$UPDATE_SCRIPT" | az vm run-command invoke \
    --resource-group "$RESOURCE_GROUP" \
    --name "$VM_NAME" \
    --command-id RunShellScript \
    --scripts @- 2>&1)

# Check if command succeeded
if echo "$RESULT" | grep -q "✅ OpenClaw service restarted successfully"; then
    print_success "Secrets updated successfully!"
    echo ""
    print_header "✅ Update Complete"
    echo ""
    echo "OpenClaw is now running with updated secrets."
    echo ""
    echo -e "${YELLOW}Verify by checking service logs:${NC}"
    echo "  az vm run-command invoke \\"
    echo "    --resource-group $RESOURCE_GROUP \\"
    echo "    --name $VM_NAME \\"
    echo "    --command-id RunShellScript \\"
    echo "    --scripts 'journalctl -u openclaw -n 20 --no-pager'"
    echo ""
else
    print_error "Failed to update secrets or restart service"
    echo ""
    echo "Command output:"
    echo "$RESULT"
    echo ""
    echo "Troubleshooting:"
    echo "  1. Check VM is running: az vm show -d --resource-group $RESOURCE_GROUP --name $VM_NAME"
    echo "  2. Check service status manually via Serial Console"
    echo "  3. Restore backup: cp /etc/openclaw/.env.backup.* /etc/openclaw/.env"
    exit 1
fi

print_success "Secrets update complete! 🔑"
