# OpenClaw Azure

**One-click deployment of your personal AI assistant to Azure**

Deploy your own private [OpenClaw](https://github.com/openclaw/openclaw) AI assistant powered by Anthropic Claude on an Azure Virtual Machine. Persistent filesystem lets you install packages dynamically via chat. Perfect for non-technical users who want their own AI assistant without the complexity.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Faerolalit%2Fopenclaw-azure%2Fmain%2Fdeploy%2Fazuredeploy.json/createUIDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2Faerolalit%2Fopenclaw-azure%2Fmain%2Fdeploy%2FcreateUiDefinition.json" target="_blank"><img src="https://aka.ms/deploytoazurebutton" /></a>

## What You Get

- **Private AI Bot** for Telegram powered by Anthropic Claude
- **Persistent Filesystem** - Install packages via chat, they survive restarts
- **Secure** - Automatic IP restrictions + HTTPS-only + optional VM backups
- **One-Click Deploy** - No coding or DevOps knowledge required
- **Control UI** - Web-based management interface with auto-generated access token

## Quick Start

### Prerequisites

You'll need:

1. **Azure Account** ([sign up free](https://azure.microsoft.com/free))
2. **Telegram Bot Token** ([setup guide](#telegram-setup)) - from @BotFather
3. **Anthropic API Key** ([get yours here](https://console.anthropic.com)) - must start with `sk-ant-`

### Deploy to Azure

**CLI Deploy (For Developers)**

```bash
# Clone the repository
git clone https://github.com/aerolalit/openclaw-azure.git
cd openclaw-azure

# Setup your configuration
cp deploy/parameters.json.example deploy/parameters.json
# Edit deploy/parameters.json with your tokens

# Deploy
./deploy/deploy.sh
```

**That's it!**

> For detailed deployment instructions, see the [Deployment Guide](docs/VM-DEPLOYMENT.md).

---

## Repository Structure

```
openclaw-azure/
├── deploy/                    # Deployment files
│   ├── azuredeploy.json      # ARM template
│   ├── deploy.sh             # Deployment script
│   ├── update-secrets.sh     # Update secrets on deployed VM
│   └── parameters.json.example # Configuration template
│
├── docs/                      # Documentation
│   ├── VM-DEPLOYMENT.md      # Deployment guide
│   ├── CONTRIBUTING.md       # Contribution guidelines
│   ├── DEVELOPMENT.md        # Developer guide
│   └── guides/               # Step-by-step guides
│
├── scripts/                   # Utility scripts
│   └── cleanup-deployments.sh # Clean up test deployments
│
└── README.md                  # You are here!
```

---

## Setup Guides

### Telegram Setup

1. **Start Chat with BotFather**
   - Open Telegram and search for `@BotFather`
   - Start a chat and type `/start`

2. **Create Your Bot**
   - Type `/newbot`
   - Give your bot a display name (e.g., "My AI Assistant")
   - Give your bot a username ending in "bot" (e.g., `MyAssistantBot`)

3. **Get Your Token**
   - Copy the token BotFather gives you
   - Format: `123456789:ABCdef1234567890abcdef1234567890ABC`
   - **Save this token** - you'll need it for deployment

4. **Get Your Telegram User ID (Optional)**
   - Open Telegram and search for [@userinfobot](https://t.me/userinfobot)
   - Send any message to it — it will reply with your numeric user ID (e.g., `455368171`)
   - **Save this ID** — use it in the `telegramUserId` parameter for automatic bot pairing (works out of the box)

5. **Configure Privacy (Important!)**
   - Type `/mybots` → Select your bot → "Bot Settings" → "Group Privacy" → "Disable"
   - This lets your bot see all messages (not just mentions)

### Anthropic API Key

**Method 1: Console (Recommended)**

1. Go to [Anthropic Console](https://console.anthropic.com)
2. Sign up/Sign in
3. Go to "API Keys" section
4. Click "Create Key"
5. **Save this key** (starts with `sk-ant-api03-`)

**Method 2: Claude CLI**

1. Install Claude CLI: `npm install -g @anthropic-ai/claude-cli`
2. Run: `claude setup-token`
3. **Save this key** (starts with `sk-ant-oat01-`)

Both token types work with OpenClaw!

---

## Cost Breakdown

Estimated monthly costs:

| Component            | Cost        | Description                 |
| -------------------- | ----------- | --------------------------- |
| VM (Standard_B1ms)   | ~$18        | 1 vCPU, 2 GB RAM, 30 GB SSD |
| VM Backup (optional) | $5-10       | Daily backups (incremental) |
| Public IP            | $3-4        | Static IP with DNS          |
| **Total**            | **~$22-30** | Default B1ms, no backup     |

**Cost Tips:**

- Use Standard_B1s for testing (~$10/month)
- Use Standard_B2s for heavier workloads (~$40/month)
- Enable auto-shutdown for dev environments (saves ~50%)
- Backups are optional (disabled by default)

---

## Deployment Parameters

Parameters are configured in `deploy/parameters.json`:

| Parameter            | Required | Description                                                                                | Example            |
| -------------------- | -------- | ------------------------------------------------------------------------------------------ | ------------------ |
| **appName**          | Yes      | Short name for your bot (3-12 chars)                                                       | `mybot`            |
| **location**         | Yes      | Azure region                                                                               | `westeurope`       |
| **anthropicApiKey**  | Yes      | Anthropic Claude API key                                                                   | `sk-ant-api03-...` |
| **telegramBotToken** | Yes      | Telegram bot token from @BotFather                                                         | `123456789:ABC...` |
| **telegramUserId**   | No       | Your Telegram numeric user ID (message [@userinfobot](https://t.me/userinfobot) to get it) | `455368171`        |
| **enableBackup**     | No       | Enable daily VM backups                                                                    | `false`            |

Additional CLI options (not in parameters.json):

| Option               | Description                   | Default         |
| -------------------- | ----------------------------- | --------------- |
| `--vm-size`          | VM size                       | `Standard_B1ms` |
| `--auto-shutdown`    | Auto-shutdown at 11 PM UTC    | Disabled        |
| `--reuse-group NAME` | Reuse existing resource group | New timestamped |
| `--admin-password`   | VM admin password             | Auto-generated  |

**Notes:**

- Gateway token is auto-generated during deployment
- Admin password is auto-generated (saved to credentials file)
- Your IP is auto-detected for NSG restrictions

---

## After Deployment

### Check if it's working

1. **Open your bot** in Telegram (search for @YourBotName)
2. **Send a message** like "Hello!" - it should respond
3. **Open the Control UI** URL from the deployment output to manage your bot

**Check logs:**

```bash
az vm run-command invoke \
  --resource-group <your-resource-group> \
  --name <your-vm-name> \
  --command-id RunShellScript \
  --scripts 'journalctl -u openclaw -n 50 --no-pager'
```

### Troubleshooting

**Telegram bot doesn't respond?**

- Wait 5-10 minutes for cloud-init to finish installing OpenClaw
- Make sure you disabled "Group Privacy" for your bot (see setup guide)
- Try typing `/start` to your bot first
- Check that the token format is correct (numbers:letters)
- Check Anthropic API key is valid and starts with `sk-ant-`
- Check VM logs for errors (see above)

**Deployment failed?**

- Check all required fields are filled in `deploy/parameters.json`
- Ensure Telegram bot token is provided
- Verify Anthropic API key starts with `sk-ant-`
- Ensure app name is 3-12 characters, letters/numbers only
- Try a different Azure region

For more issues, see the complete **[Troubleshooting Guide](./docs/VM-DEPLOYMENT.md#troubleshooting)**

---

## Security Features

### Automatic IP Restriction (Defense-in-Depth)

Your deployment includes **automatic IP restriction** for enhanced security:

- **Auto-detected during deployment** - Your public IP is automatically added as the only allowed IP
- **Defense-in-depth** - Gateway token + IP restriction (two factors required)
- **Network-level protection** - Blocks unauthorized access before reaching the application
- **HTTPS-only** - Automatic Let's Encrypt certificate via Caddy reverse proxy

**How it works:**

1. **CLI Deployment** (`./deploy/deploy.sh`):
   - Script auto-detects your public IP
   - Configures NSG to only allow your IP on port 443
   - Shows your IP in deployment output

2. **Azure Portal Deployment**:
   - Form prompts you to enter your IP address
   - Visit https://api.ipify.org to find your IP
   - Enter it in the deployment form

**What this protects against:**

- Leaked gateway token in logs/screenshots → Attacker blocked (wrong IP)
- Accidentally shared credentials → Recipient blocked (wrong IP)
- Brute force attacks → Blocked at network layer (wrong IP)
- Unauthorized access from compromised networks → Blocked (wrong IP)

### Managing IP Restrictions

**When your IP changes (home internet, VPN, etc.):**

**Option 1 - Azure Portal:**

```
Portal → Network Security Groups → [your-app]-nsg → Inbound security rules → Add
```

**Option 2 - Azure CLI (Quick):**

```bash
az network nsg rule create \
  --resource-group <your-resource-group> \
  --nsg-name <your-app>-nsg \
  --name AllowNewIP \
  --priority 1100 \
  --source-address-prefixes $(curl -s https://api.ipify.org)/32 \
  --destination-port-ranges 443 \
  --protocol Tcp --access Allow
```

**Option 3 - Add team member:**

```bash
az network nsg rule create \
  --resource-group <your-resource-group> \
  --nsg-name <your-app>-nsg \
  --name AllowColleague \
  --priority 1101 \
  --source-address-prefixes 198.51.100.50/32 \
  --destination-port-ranges 443 \
  --protocol Tcp --access Allow
```

For complete IP restriction management guide, see [docs/VM-DEPLOYMENT.md](docs/VM-DEPLOYMENT.md#2-managing-ip-restrictions).

### Additional Security Layers

- **HTTPS-Only** - Automatic Let's Encrypt certificate via Caddy
- **IP Restricted** - Only your IP can access the VM
- **SSH Disabled** - No SSH port open; use Azure Serial Console for emergencies
- **Secrets on VM** - Stored at `/etc/openclaw/.env`, encrypted at rest
- **Optional Backups** - Full VM backup including installed packages and secrets (enable with `enableBackup` parameter)

**Security Note:** Due to OpenClaw bug #7384, device pairing is disabled (`dangerouslyDisableDeviceAuth: true`). IP restrictions mitigate this by adding network-level access control. Once OpenClaw fixes the bug, device pairing can be re-enabled for additional security.

---

## Advanced Usage

### Installing Packages via Chat

This is the key benefit of the VM deployment. Users can ask the bot directly:

```
User: Install pandas library
Bot: [Runs: pip install pandas]
Bot: Installed successfully!

User: Install ffmpeg
Bot: [Runs: apt-get install ffmpeg]
Bot: Installed successfully!
```

Packages persist across restarts and are included in daily backups.

### Updating Secrets

```bash
# Edit parameters.json with new secrets, then:
./deploy/update-secrets.sh --resource-group <your-resource-group>
```

### Backup and Restore

When backups are enabled (`enableBackup: true`), your VM is backed up daily at 2:00 AM UTC. Backups include:

- OS disk with all configurations
- Installed packages
- Secrets in `/etc/openclaw/.env`

To restore: Azure Portal → Recovery Services vaults → [your-vault] → Backup Items → Restore VM

See [docs/VM-DEPLOYMENT.md](docs/VM-DEPLOYMENT.md#backup-and-restore) for details.

---

## Support

- **Deployment Guide**: [docs/VM-DEPLOYMENT.md](./docs/VM-DEPLOYMENT.md) - Detailed deployment docs
- **Troubleshooting**: [docs/VM-DEPLOYMENT.md#troubleshooting](./docs/VM-DEPLOYMENT.md#troubleshooting) - Common issues and solutions
- **Bug Reports**: [GitHub Issues](https://github.com/aerolalit/openclaw-azure/issues)
- **Questions**: [GitHub Discussions](https://github.com/aerolalit/openclaw-azure/discussions)

---

## License

MIT License - feel free to fork and customize!

## Contributing

We welcome contributions! Whether it's:

- Bug fixes
- Documentation improvements
- New features
- Ideas and suggestions

See [docs/CONTRIBUTING.md](./docs/CONTRIBUTING.md) for guidelines.

---

**Made with love for the AI community**

_Want to make AI assistants accessible to everyone, not just developers._
