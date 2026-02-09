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
