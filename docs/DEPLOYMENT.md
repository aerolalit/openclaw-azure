# OpenClaw Azure Deployment Guide

## Quick Start

### 1. Setup Parameters File

```bash
# Copy the example file
cp deploy/parameters.json.example deploy/parameters.json

# Edit with your tokens
nano deploy/parameters.json
# or
code deploy/parameters.json
```

**Required tokens:**
- At least one messaging platform token (Discord, Telegram, Slack, or WhatsApp)
- Anthropic API key (required)

**Optional tokens:**
- OpenAI, Groq, Cohere (additional AI models)
- ElevenLabs (text-to-speech)
- GitHub, Notion (integrations)
- Brave Search (enhanced search)

### 2. Deploy

```bash
# Simple deployment (creates new timestamped resource group)
./deploy/deploy.sh

# Quick deployment (no confirmation)
./deploy/deploy.sh --no-confirm

# Override location
./deploy/deploy.sh --location eastus

# Production deployment (reuse same resource group)
./deploy/deploy.sh --reuse-group openclaw-prod-rg
```

## Deployment Options

### Testing & Development
**Best for:** Trying things out, testing changes

```bash
./deploy/deploy.sh
```

- Creates NEW resource group with timestamp: `openclaw-mybot-20260209-143022-rg`
- Clean state every deployment
- Easy to delete: `az group delete --name <resource-group> --yes --no-wait`

### Production
**Best for:** Long-term deployments, production use

```bash
./deploy/deploy.sh --reuse-group openclaw-prod-rg
```

- Reuses same resource group
- Preserves storage and configuration
- Updates in-place

## Advanced Usage

### Override Specific Settings

```bash
# Use different region
./deploy/deploy.sh --location westus

# Higher resources
./deploy/deploy.sh --cpu 2.0 --memory 4Gi

# Production with overrides
./deploy/deploy.sh --reuse-group openclaw-prod-rg --cpu 2.0
```

### CI/CD Integration

```bash
# Automated deployments (no prompts)
./deploy/deploy.sh --no-confirm
```

## Security Best Practices

### ✅ DO
- Keep `parameters.json` in `.gitignore` (already configured)
- Use `parameters.json.example` for the repository
- Store real tokens only in your local `parameters.json`
- Use Azure Key Vault for production secrets
- Rotate tokens regularly

### ❌ DON'T
- Never commit `parameters.json` to git
- Don't share `parameters.json` in screenshots/logs
- Don't use production tokens for testing

## IP Restrictions (Security Feature)

### Automatic IP Detection (CLI Deployment)

When deploying via `./deploy/deploy.sh`, your public IP is **automatically detected** and configured as the only allowed IP for accessing the Control UI.

```bash
./deploy/deploy.sh

# Output:
# 🔐 Detecting your public IP address for access control...
# ✅ Detected your public IP: 203.0.113.45
# Security: Only this IP can access Control UI
```

**What happens:**
1. Script detects your IP via https://api.ipify.org
2. Adds IP restriction to Container App ingress
3. Only your IP can access the Control UI
4. Gateway token + IP restriction = defense-in-depth security

**If auto-detection fails:**
```bash
# You'll be prompted to enter your IP manually
Enter your public IP address (required): 203.0.113.45
```

To find your IP: Visit https://api.ipify.org in your browser

### Azure Portal Deployment

When deploying via the "Deploy to Azure" button:

1. **Parameter field shows:**
   ```
   🔐 REQUIRED: At least one IP address must be provided for security.

   To find your IP:
   (1) Open https://api.ipify.org in new tab
   (2) Copy IP shown
   (3) Enter as ["YOUR_IP/32"]

   Example: ["203.0.113.45/32"]
   ```

2. **User action:**
   - Open https://api.ipify.org → see `203.0.113.45`
   - Enter in form: `["203.0.113.45/32"]`
   - Deploy

### Managing IP Restrictions Post-Deployment

#### When Your IP Changes

**Scenario:** Your home internet reconnected, IP changed from `203.0.113.45` to `203.0.113.46`

**Solution 1 - Azure Portal (Easiest):**
1. Go to Azure Portal → Container Apps
2. Click your OpenClaw app
3. Left menu → **Ingress**
4. Scroll to **IP Security Restrictions**
5. Click **+ Add**
6. Fill in:
   - Name: `AllowNewIP`
   - IP Address Range: `203.0.113.46/32`
   - Action: `Allow`
7. Click **Add**, then **Save**

**Solution 2 - Azure CLI (Fast):**
```bash
# Auto-detect and update in one command
az containerapp update \
  --name openclaw-abc123 \
  --resource-group openclaw-rg \
  --set properties.configuration.ingress.ipSecurityRestrictions="[{\"name\":\"CurrentIP\",\"ipAddressRange\":\"$(curl -s https://api.ipify.org)/32\",\"action\":\"Allow\"}]"
```

**Solution 3 - Add without replacing:**
```bash
az containerapp ingress access-restriction set \
  --name openclaw-abc123 \
  --resource-group openclaw-rg \
  --rule-name "AllowNewIP" \
  --ip-address "203.0.113.46/32" \
  --action Allow
```

#### Adding Team Members

**Scenario:** Your colleague needs access from IP `198.51.100.50`

```bash
az containerapp ingress access-restriction set \
  --name openclaw-abc123 \
  --resource-group openclaw-rg \
  --rule-name "AllowColleague" \
  --ip-address "198.51.100.50/32" \
  --action Allow
```

Or use Azure Portal (Method above).

#### Office Network (Multiple Users, Same IP)

**Scenario:** Entire office shares one public IP via NAT gateway

```bash
# Allow entire office subnet
az containerapp ingress access-restriction set \
  --name openclaw-abc123 \
  --resource-group openclaw-rg \
  --rule-name "AllowOffice" \
  --ip-address "203.0.113.0/24" \
  --action Allow
```

#### Locked Out (IP Changed, Can't Access Portal)

**Solution - Use Azure Cloud Shell:**
1. Go to https://shell.azure.com (works from any IP)
2. Run the CLI update command from Cloud Shell
3. Add your new IP, then you can access Portal normally

### List Current IP Restrictions

```bash
az containerapp ingress show \
  --name openclaw-abc123 \
  --resource-group openclaw-rg \
  --query "ipSecurityRestrictions[].{Name:name,IP:ipAddressRange}" \
  -o table
```

### Security Benefits

✅ **Defense-in-depth:** Gateway token + IP restriction (two factors)
✅ **Blocks remote attackers:** Even if token leaks, wrong IP = blocked
✅ **Network-level protection:** Blocked before reaching application
✅ **Compliance-friendly:** Meets network access control requirements
✅ **Audit trail:** Azure logs show which IPs accessed the service

### Why IP Restrictions Are Required

Unlike some services, this template **requires** at least one IP address for security:

- **Without IP restrictions:** Anyone with gateway token can access from anywhere
- **With IP restrictions:** Attacker needs both token AND allowed IP
- **90% reduction** in attack surface for remote threats

This protects against:
- Leaked tokens in logs/screenshots
- Accidentally shared credentials
- Brute force attacks from random IPs
- Unauthorized access from compromised networks

## Troubleshooting

### "parameters.json not found"
```bash
cp deploy/parameters.json.example deploy/parameters.json
# Edit with your tokens
```

### "Azure CLI not installed"
```bash
# macOS
brew install azure-cli

# Windows
winget install Microsoft.AzureCLI

# Linux
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

### "Not logged in to Azure CLI"
```bash
az login
```

### Deployment Failed
1. Check all required tokens are filled in `deploy/parameters.json`
2. Ensure at least one messaging platform token is provided
3. Verify Anthropic API key starts with `sk-ant-`
4. Try a different Azure region: `./deploy/deploy.sh --location westus`

## Resource Cleanup

### Delete Single Deployment
```bash
az group delete --name openclaw-mybot-20260209-143022-rg --yes --no-wait
```

### Delete All OpenClaw Deployments
```bash
# Use the cleanup utility
./scripts/cleanup-deployments.sh

# Or manually:
az group list --query "[?starts_with(name, 'openclaw-')].name" -o tsv | \
  xargs -I {} az group delete --name {} --yes --no-wait
```

## Cost Management

- Each deployment costs ~$20-30/month
- Delete test deployments when done
- Use `--reuse-group` for production to avoid multiple resource groups
- Monitor costs in Azure Portal

## Need Help?

- Run `./deploy/deploy.sh --help` for all options
- Check [README.md](../README.md) for general documentation
- See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for common issues
- Open an issue on GitHub
