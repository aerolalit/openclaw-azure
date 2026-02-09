#!/bin/bash

# OpenClaw Azure Cleanup Utility
# Helps clean up test deployments

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Check if logged in
if ! az account show &> /dev/null; then
    echo -e "${RED}❌ Not logged in to Azure CLI.${NC}"
    echo "Run: az login"
    exit 1
fi

SUBSCRIPTION=$(az account show --query "name" -o tsv)
echo ""
print_header "🧹 OpenClaw Deployment Cleanup"
echo ""
echo -e "${BLUE}Subscription:${NC} $SUBSCRIPTION"
echo ""

# List all OpenClaw resource groups
echo -e "${YELLOW}Finding OpenClaw deployments...${NC}"
GROUPS=$(az group list --query "[?starts_with(name, 'openclaw-')].name" -o tsv)

if [ -z "$GROUPS" ]; then
    echo -e "${GREEN}✅ No OpenClaw deployments found${NC}"
    exit 0
fi

echo ""
echo "Found OpenClaw resource groups:"
echo ""
echo "$GROUPS" | nl
echo ""

# Count deployments
COUNT=$(echo "$GROUPS" | wc -l | tr -d ' ')
echo -e "${YELLOW}Total:${NC} $COUNT deployment(s)"
echo ""

# Ask for confirmation
echo -e "${RED}⚠️  WARNING:${NC} This will DELETE all OpenClaw resource groups and their contents!"
echo ""
read -p "Are you sure you want to continue? (type 'yes' to confirm): " -r
echo

if [[ ! $REPLY == "yes" ]]; then
    echo "Cleanup cancelled."
    exit 0
fi

# Delete all resource groups
echo ""
echo -e "${YELLOW}Deleting resource groups...${NC}"
echo ""

for group in $GROUPS; do
    echo -e "${BLUE}🗑️  Deleting:${NC} $group"
    az group delete --name "$group" --yes --no-wait
done

echo ""
echo -e "${GREEN}✅ Cleanup initiated!${NC}"
echo ""
echo "Resource groups are being deleted in the background."
echo "This may take 5-10 minutes to complete."
echo ""
echo "To check status:"
echo "  az group list --query \"[?starts_with(name, 'openclaw-')].name\" -o table"
