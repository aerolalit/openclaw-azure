# OpenClaw Azure Deployment Guide

## Quick Start

### 1. Setup Parameters File

```bash
# Copy the example file
cp parameters.json.example parameters.json

# Edit with your tokens
nano parameters.json
# or
code parameters.json
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
./deploy.sh

# Quick deployment (no confirmation)
./deploy.sh --no-confirm

# Override location
./deploy.sh --location eastus

# Production deployment (reuse same resource group)
./deploy.sh --reuse-group openclaw-prod-rg
```

## Deployment Options

### Testing & Development

**Best for:** Trying things out, testing changes

```bash
./deploy.sh
```

- Creates NEW resource group with timestamp: `openclaw-mybot-20260209-143022-rg`
- Clean state every deployment
- Easy to delete: `az group delete --name <resource-group> --yes --no-wait`

### Production

**Best for:** Long-term deployments, production use

```bash
./deploy.sh --reuse-group openclaw-prod-rg
```

- Reuses same resource group
- Preserves storage and configuration
- Updates in-place

## Advanced Usage

### Override Specific Settings

```bash
# Use different region
./deploy.sh --location westus

# Higher resources
./deploy.sh --cpu 2.0 --memory 4Gi

# Production with overrides
./deploy.sh --reuse-group openclaw-prod-rg --cpu 2.0
```

### CI/CD Integration

```bash
# Automated deployments (no prompts)
./deploy.sh --no-confirm

# Use different parameters file
# (Edit deploy.sh line 16: PARAMETERS_FILE="parameters.prod.json")
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
cp parameters.json.example parameters.json
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

1. Check all required tokens are filled in `parameters.json`
2. Ensure at least one messaging platform token is provided
3. Verify Anthropic API key starts with `sk-ant-`
4. Try a different Azure region: `./deploy.sh --location westus`

## Migration from quick-deploy.sh

If you were using `quick-deploy.sh`:

```bash
# Old way
./quick-deploy.sh

# New way (same behavior)
./deploy.sh

# With confirmation skip (like old quick-deploy)
./deploy.sh --no-confirm
```

The new `deploy.sh` combines the best of both scripts:

- Uses `parameters.json` (simpler, more secure)
- Creates timestamped resource groups by default (clean deployments)
- Adds confirmation prompts (safety)
- Allows CLI overrides (flexibility)
- Better help and documentation

## Resource Cleanup

### Delete Single Deployment

```bash
az group delete --name openclaw-mybot-20260209-143022-rg --yes --no-wait
```

### Delete All OpenClaw Deployments

```bash
# List all OpenClaw resource groups
az group list --query "[?starts_with(name, 'openclaw-')].name" -o table

# Delete all (careful!)
az group list --query "[?starts_with(name, 'openclaw-')].name" -o tsv | \
  xargs -I {} az group delete --name {} --yes --no-wait
```

## Cost Management

- Each deployment costs ~$20-30/month
- Delete test deployments when done
- Use `--reuse-group` for production to avoid multiple resource groups
- Monitor costs in Azure Portal

## Need Help?

- Run `./deploy.sh --help` for all options
- Check [README.md](README.md) for general documentation
- See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for common issues
- Open an issue on GitHub
