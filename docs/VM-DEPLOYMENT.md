# OpenClaw Azure VM Deployment Guide

## Why Use VM Deployment?

**Choose VM deployment if:**
- ✅ **Low-tech/no-tech users** who will ask the bot to install packages via chat
- ✅ Need **persistent filesystem** that survives restarts
- ✅ Want to **install system packages** (Python libraries, Node modules, system tools)
- ✅ Need packages to be **automatically restored** from backup
- ✅ Want **full control** over the system environment

**Choose Container Apps deployment if:**
- ❌ Don't need to install packages dynamically
- ❌ Static configuration is sufficient
- ❌ Want lowest cost (~$20/month vs ~$40/month for VM)

---

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

### 2. Deploy VM

```bash
# Simple deployment (creates new timestamped resource group)
./deploy/deploy-vm.sh

# Quick deployment (no confirmation)
./deploy/deploy-vm.sh --no-confirm

# Override location
./deploy/deploy-vm.sh --location eastus

# Production deployment (reuse same resource group)
./deploy/deploy-vm.sh --reuse-group openclaw-prod-rg

# Development with auto-shutdown (saves costs)
./deploy/deploy-vm.sh --auto-shutdown
```

---

## Deployment Options

### VM Sizes

Choose based on your workload:

| VM Size | vCPU | RAM | Cost/Month | Use Case |
|---------|------|-----|------------|----------|
| **Standard_B1s** | 1 | 1 GB | ~$10 | Testing, light use |
| **Standard_B2s** | 2 | 4 GB | ~$40 | **Recommended** - Production |
| **Standard_B2ms** | 2 | 8 GB | ~$80 | Heavy workloads, many packages |

```bash
# Deploy with specific VM size
./deploy/deploy-vm.sh --vm-size Standard_B2ms
```

### Testing & Development

**Best for:** Trying things out, testing changes

```bash
./deploy/deploy-vm.sh --auto-shutdown
```

- Creates NEW resource group with timestamp: `openclaw-mybot-vm-20260209-143022-rg`
- Clean state every deployment
- Auto-shutdown at 11 PM UTC (saves costs)
- Easy to delete: `az group delete --name <resource-group> --yes --no-wait`

### Production

**Best for:** Long-term deployments, production use

```bash
./deploy/deploy-vm.sh --reuse-group openclaw-prod-rg
```

- Reuses same resource group
- Preserves storage and configuration
- Updates in-place
- Daily backups enabled

---

## Security Features

### 1. IP Restrictions (Network Security Group)

**Automatic IP Detection:**

When deploying via `./deploy/deploy-vm.sh`, your public IP is **automatically detected** and configured as the only allowed IP for accessing the VM.

```bash
./deploy/deploy-vm.sh

# Output:
# 🔐 Detecting your public IP address for access control...
# ✅ Detected your public IP: 203.0.113.45
# Security: Only this IP can access VM (HTTPS)
```

**What happens:**
1. Script detects your IP via https://api.ipify.org
2. Adds NSG rule allowing HTTPS (port 443) from your IP only
3. SSH disabled by default (Serial Console for emergency)
4. Gateway token + IP restriction = defense-in-depth security

### 2. Managing IP Restrictions

#### When Your IP Changes

**Scenario:** Your home internet reconnected, IP changed from `203.0.113.45` to `203.0.113.46`

**Solution 1 - Azure Portal (Easiest):**
1. Go to Azure Portal → Network Security Groups
2. Click your OpenClaw NSG (e.g., `mybot-nsg`)
3. Left menu → **Inbound security rules**
4. Click **+ Add**
5. Fill in:
   - Source: `IP Addresses`
   - Source IP addresses: `203.0.113.46/32`
   - Destination port ranges: `443`
   - Protocol: `TCP`
   - Action: `Allow`
   - Priority: `1100`
   - Name: `AllowNewIP`
6. Click **Add**

**Solution 2 - Azure CLI (Fast):**
```bash
az network nsg rule create \
  --resource-group openclaw-mybot-vm-rg \
  --nsg-name mybot-nsg \
  --name AllowNewIP \
  --priority 1100 \
  --source-address-prefixes 203.0.113.46/32 \
  --destination-port-ranges 443 \
  --protocol Tcp \
  --access Allow
```

#### Adding Team Members

**Scenario:** Your colleague needs access from IP `198.51.100.50`

```bash
az network nsg rule create \
  --resource-group openclaw-prod-rg \
  --nsg-name mybot-nsg \
  --name AllowColleague \
  --priority 1101 \
  --source-address-prefixes 198.51.100.50/32 \
  --destination-port-ranges 443 \
  --protocol Tcp \
  --access Allow
```

### 3. SSH Disabled by Default

**Why:** For security, SSH is disabled. Use **Serial Console** for emergency access.

**How to access Serial Console:**
1. Go to Azure Portal → Virtual Machines
2. Click your OpenClaw VM
3. Left menu → **Serial Console**
4. Login with admin credentials from deployment

**Enable SSH if needed (not recommended):**
```bash
# Add NSG rule for SSH (port 22)
az network nsg rule create \
  --resource-group openclaw-prod-rg \
  --nsg-name mybot-nsg \
  --name AllowSSH \
  --priority 1200 \
  --source-address-prefixes YOUR_IP/32 \
  --destination-port-ranges 22 \
  --protocol Tcp \
  --access Allow

# SSH to VM
ssh azureuser@<vm-dns-name>
```

### 4. Secrets Stored on VM

**Location:** `/etc/openclaw/.env`

**Why this approach?**
- ✅ Simple for low-tech users
- ✅ No Key Vault complexity
- ✅ Easy to update via chat or Control UI
- ✅ Included in VM backups (encrypted at rest)
- ✅ Restored automatically when VM is restored

**Security measures:**
- File permissions: `600` (root only)
- Azure disk encryption enabled
- Backups are encrypted
- IP restrictions prevent unauthorized access

---

## Managing Secrets

### Initial Deployment

Secrets from `parameters.json` are automatically written to `/etc/openclaw/.env` during VM provisioning.

### Updating Secrets

**Option 1: Update Script (Recommended)**

```bash
# 1. Edit parameters.json with new secrets
nano deploy/parameters.json

# 2. Run update script
./deploy/update-secrets.sh --resource-group openclaw-mybot-vm-rg

# 3. Confirm update
# Secrets are updated and OpenClaw restarts automatically
```

**Option 2: Manual Update via Azure CLI**

```bash
# Create update script
cat > update-telegram-token.sh << 'EOF'
#!/bin/bash
sed -i 's/TELEGRAM_BOT_TOKEN=.*/TELEGRAM_BOT_TOKEN=NEW_TOKEN_HERE/' /etc/openclaw/.env
systemctl restart openclaw
EOF

# Run on VM
az vm run-command invoke \
  --resource-group openclaw-mybot-vm-rg \
  --name mybot-vm \
  --command-id RunShellScript \
  --scripts @update-telegram-token.sh
```

**Option 3: Serial Console (Emergency)**

1. Azure Portal → Virtual Machines → mybot-vm → Serial Console
2. Login with admin credentials
3. Edit: `sudo nano /etc/openclaw/.env`
4. Restart: `sudo systemctl restart openclaw`

---

## Post-Deployment Management

### Check VM Status

```bash
# VM power state
az vm show -d \
  --resource-group openclaw-mybot-vm-rg \
  --name mybot-vm \
  --query "powerState" -o tsv

# Expected: VM running
```

### Check OpenClaw Installation Status

```bash
# Wait for cloud-init to complete (5-10 minutes)
az vm run-command invoke \
  --resource-group openclaw-mybot-vm-rg \
  --name mybot-vm \
  --command-id RunShellScript \
  --scripts 'cloud-init status --wait'

# Expected: status: done
```

### Check OpenClaw Service

```bash
# Service status
az vm run-command invoke \
  --resource-group openclaw-mybot-vm-rg \
  --name mybot-vm \
  --command-id RunShellScript \
  --scripts 'systemctl status openclaw'

# Expected: Active: active (running)
```

### View OpenClaw Logs

```bash
# Last 50 lines
az vm run-command invoke \
  --resource-group openclaw-mybot-vm-rg \
  --name mybot-vm \
  --command-id RunShellScript \
  --scripts 'journalctl -u openclaw -n 50 --no-pager'

# Follow logs live (via Serial Console)
sudo journalctl -u openclaw -f
```

### Restart OpenClaw Service

```bash
az vm run-command invoke \
  --resource-group openclaw-mybot-vm-rg \
  --name mybot-vm \
  --command-id RunShellScript \
  --scripts 'systemctl restart openclaw && sleep 3 && systemctl status openclaw'
```

### Stop/Start VM

```bash
# Stop VM (deallocate to save costs)
az vm deallocate \
  --resource-group openclaw-mybot-vm-rg \
  --name mybot-vm

# Start VM
az vm start \
  --resource-group openclaw-mybot-vm-rg \
  --name mybot-vm
```

---

## Backup and Restore

### Automatic Backups

**What's included:**
- ✅ OS disk (Ubuntu with all configurations)
- ✅ Installed packages (OpenClaw + dependencies)
- ✅ System files (/etc/openclaw/.env with secrets)
- ✅ User data (via Azure Files mount at /workspace)

**Backup schedule:**
- Daily at 2:00 AM UTC
- Retention: 7 days (default), 14 or 30 days (configurable)

**Backup location:**
- Azure Recovery Services Vault (encrypted)
- No manual intervention required

### View Backup Status

```bash
# List recovery points
az backup recoverypoint list \
  --resource-group openclaw-mybot-vm-rg \
  --vault-name mybot-vault \
  --container-name IaasVMContainer\;iaasvmcontainerv2\;openclaw-mybot-vm-rg\;mybot-vm \
  --item-name vm\;iaasvmcontainerv2\;openclaw-mybot-vm-rg\;mybot-vm \
  --query "[].{Name:name, Time:properties.recoveryPointTime}" \
  -o table
```

### Restore from Backup

**Option 1: Restore Full VM (Recommended)**

```bash
# This creates a new VM from backup
az backup restore restore-disks \
  --resource-group openclaw-mybot-vm-rg \
  --vault-name mybot-vault \
  --container-name IaasVMContainer\;iaasvmcontainerv2\;openclaw-mybot-vm-rg\;mybot-vm \
  --item-name vm\;iaasvmcontainerv2\;openclaw-mybot-vm-rg\;mybot-vm \
  --rp-name <recovery-point-name> \
  --storage-account <storage-account> \
  --restore-mode AlternateLocation \
  --target-resource-group openclaw-restored-rg
```

**Option 2: Azure Portal (Easier)**

1. Azure Portal → Recovery Services vaults → mybot-vault
2. Backup Items → Azure Virtual Machine
3. Click your VM → Restore VM
4. Select restore point (date/time)
5. Choose:
   - **Replace existing** (overwrites current VM)
   - **Create new** (creates separate VM)
6. Click **Restore**
7. Wait 15-30 minutes for restore to complete

**What's restored:**
- ✅ Entire VM state at backup time
- ✅ All installed packages
- ✅ OpenClaw configuration
- ✅ Secrets in /etc/openclaw/.env
- ✅ System packages and libraries

**What's NOT in VM backup:**
- ❌ User data in /workspace (stored in Azure Files - separate backup)

### Azure Files Backup (User Data)

Azure Files (mounted at `/workspace`) has its own backup:
- Enabled automatically during deployment
- Snapshot-based (instant)
- 30-day retention (default)

**Restore user data:**

1. Azure Portal → Storage Accounts → (your storage account)
2. File shares → openclaw-data
3. Click **Restore share**
4. Select snapshot (date/time)
5. Restore to new share or overwrite existing

---

## Installing Packages Dynamically

**This is the key benefit of VM deployment!**

### Via Chat (OpenClaw Bot)

Users can ask the bot directly:

```
User: Install pandas library
Bot: [Runs: pip install pandas]
Bot: Installed successfully!

User: Install ffmpeg
Bot: [Runs: apt-get install ffmpeg]
Bot: Installed successfully!
```

Packages persist across restarts and are included in backups.

### Via Azure CLI

```bash
# Install Python package
az vm run-command invoke \
  --resource-group openclaw-mybot-vm-rg \
  --name mybot-vm \
  --command-id RunShellScript \
  --scripts 'pip install pandas numpy scipy'

# Install system package
az vm run-command invoke \
  --resource-group openclaw-mybot-vm-rg \
  --name mybot-vm \
  --command-id RunShellScript \
  --scripts 'apt-get update && apt-get install -y ffmpeg'
```

### Via Serial Console

1. Azure Portal → Virtual Machines → mybot-vm → Serial Console
2. Login with admin credentials
3. Install packages:
   ```bash
   sudo pip install package-name
   sudo apt-get install package-name
   ```

---

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
4. Try a different Azure region: `./deploy/deploy-vm.sh --location westus`
5. Check Azure subscription quota for VM size

### OpenClaw Service Not Starting

```bash
# Check cloud-init status (may still be installing)
az vm run-command invoke \
  --resource-group openclaw-mybot-vm-rg \
  --name mybot-vm \
  --command-id RunShellScript \
  --scripts 'cloud-init status'

# If done, check logs
az vm run-command invoke \
  --resource-group openclaw-mybot-vm-rg \
  --name mybot-vm \
  --command-id RunShellScript \
  --scripts 'journalctl -u openclaw -n 100 --no-pager'
```

### Control UI Not Accessible

**Check 1: VM is running**
```bash
az vm show -d \
  --resource-group openclaw-mybot-vm-rg \
  --name mybot-vm \
  --query "powerState" -o tsv
```

**Check 2: IP restriction**
- Visit https://api.ipify.org to check your current IP
- If changed, add new IP to NSG (see "Managing IP Restrictions" above)

**Check 3: OpenClaw service status**
```bash
az vm run-command invoke \
  --resource-group openclaw-mybot-vm-rg \
  --name mybot-vm \
  --command-id RunShellScript \
  --scripts 'systemctl status openclaw'
```

### Azure Files Not Mounted

```bash
# Check mount status
az vm run-command invoke \
  --resource-group openclaw-mybot-vm-rg \
  --name mybot-vm \
  --command-id RunShellScript \
  --scripts 'mount | grep workspace'

# Re-mount manually
az vm run-command invoke \
  --resource-group openclaw-mybot-vm-rg \
  --name mybot-vm \
  --command-id RunShellScript \
  --scripts '/usr/local/bin/mount-azure-files.sh'
```

---

## Resource Cleanup

### Delete Single Deployment
```bash
az group delete --name openclaw-mybot-vm-20260209-143022-rg --yes --no-wait
```

### Delete All OpenClaw VM Deployments
```bash
# List VM deployments
az group list --query "[?contains(name, 'openclaw') && contains(name, 'vm')].name" -o tsv

# Delete all (careful!)
az group list --query "[?contains(name, 'openclaw') && contains(name, 'vm')].name" -o tsv | \
  xargs -I {} az group delete --name {} --yes --no-wait
```

---

## Cost Management

### Cost Breakdown

**VM (Standard_B2s):** ~$40/month
- 2 vCPU, 4 GB RAM
- Premium SSD (30 GB)

**Storage:** ~$5-10/month
- Azure Files: $0.10/GB/month (100 GB = $10)
- Backup: $0.10/GB/month (incremental)

**Networking:** ~$1-2/month
- Public IP: $0.005/hour (~$3.60/month)
- Bandwidth: First 5 GB free

**Total:** ~$45-55/month (Standard_B2s)

### Cost Optimization Tips

**1. Use Auto-Shutdown for Development**
```bash
./deploy/deploy-vm.sh --auto-shutdown
```
Saves ~$20/month if VM off 12+ hours/day.

**2. Use Smaller VM for Testing**
```bash
./deploy/deploy-vm.sh --vm-size Standard_B1s
```
Standard_B1s costs ~$10/month (vs $40 for B2s).

**3. Reduce Storage Quota**
```json
// In parameters.json
"storageShareQuota": {
  "value": 10  // 10 GB instead of 100 GB
}
```
Saves ~$9/month.

**4. Reduce Backup Retention**
```json
// In parameters.json
"backupRetentionDays": {
  "value": 7  // 7 days instead of 30
}
```
Saves ~$5-10/month.

**5. Delete Test Deployments**
```bash
# Don't forget to delete test resource groups!
az group delete --name openclaw-test-rg --yes --no-wait
```

### Monitor Costs

**Azure Portal:**
1. Cost Management + Billing
2. Cost analysis
3. Filter by resource group

**Azure CLI:**
```bash
# Check current month costs
az consumption usage list \
  --query "[?contains(instanceName, 'openclaw')]" \
  --output table
```

---

## Comparison: VM vs Container Apps

| Feature | VM Deployment | Container Apps |
|---------|---------------|----------------|
| **Persistent filesystem** | ✅ Yes | ❌ No (ephemeral) |
| **Install packages dynamically** | ✅ Yes | ❌ No |
| **Packages preserved after restart** | ✅ Yes (always) | ❌ No |
| **Full VM backup** | ✅ Yes | ❌ N/A |
| **Best for** | Low-tech users | Static configuration |
| **Cost** | ~$45-55/month | ~$20-30/month |
| **Startup time** | ~2 minutes | ~30 seconds |
| **Scaling** | Manual (resize VM) | Automatic |
| **Maintenance** | More (OS updates) | Less (managed) |

**Choose VM if:** You need persistent packages that users install via chat.

**Choose Container Apps if:** Static configuration is sufficient and you want lower cost.

---

## Need Help?

- Run `./deploy/deploy-vm.sh --help` for all options
- Check [README.md](../README.md) for general documentation
- See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for common issues
- Open an issue on GitHub

---

## Advanced Topics

### Custom Cloud-Init Script

The VM uses cloud-init for initial setup. To customize:

1. Modify `azuredeploy-vm.json` → `cloudInitScript` variable
2. Add your custom initialization steps to `runcmd:` section
3. Redeploy VM

### Monitoring and Alerts

**Enable Azure Monitor:**

```bash
az vm extension set \
  --resource-group openclaw-mybot-vm-rg \
  --vm-name mybot-vm \
  --name AzureMonitorLinuxAgent \
  --publisher Microsoft.Azure.Monitor
```

**Create alert for VM down:**

```bash
az monitor metrics alert create \
  --name openclaw-vm-down \
  --resource-group openclaw-mybot-vm-rg \
  --scopes <vm-resource-id> \
  --condition "avg Percentage CPU < 1" \
  --window-size 5m \
  --evaluation-frequency 1m
```

### HTTPS with Custom Domain

**Option 1: Caddy (Automatic HTTPS)**

VM includes Caddy for automatic HTTPS with Azure DNS.

**Option 2: Custom Domain**

1. Register domain (e.g., openclaw.example.com)
2. Point DNS to VM's public IP
3. Update Caddy configuration on VM:
   ```bash
   echo "openclaw.example.com {
     reverse_proxy localhost:18789
   }" | sudo tee /etc/caddy/Caddyfile
   sudo systemctl restart caddy
   ```
4. Caddy automatically provisions Let's Encrypt certificate

---

## Security Best Practices

### ✅ DO

- Keep `parameters.json` in `.gitignore` (already configured)
- Use `parameters.json.example` for the repository
- Store real tokens only in your local `parameters.json`
- Rotate tokens regularly (use `update-secrets.sh`)
- Enable Azure Security Center recommendations
- Monitor access logs in Azure Portal
- Use IP ranges for office networks (e.g., `203.0.113.0/24`)
- Test backups periodically by restoring to test VM

### ❌ DON'T

- Never commit `parameters.json` to git
- Don't share `parameters.json` in screenshots/logs
- Don't use production tokens for testing
- Don't disable IP restrictions without good reason
- Don't skip backups (costs are minimal)
- Don't ignore security updates (run `apt-get update` periodically)
