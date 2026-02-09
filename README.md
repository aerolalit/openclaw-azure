# OpenClaw Azure

**One-click deployment of your personal AI assistant to Azure**

Deploy your own private OpenClaw AI assistant powered by Anthropic Claude on an Azure Virtual Machine. Persistent filesystem lets you install packages dynamically via chat. Perfect for non-technical users who want their own AI assistant without the complexity.

## What You Get

- **Private AI Bot** for Discord, Telegram, Slack, or WhatsApp powered by Claude AI
- **Multi-AI Support** - Anthropic Claude (required) + optional OpenAI, Groq, Cohere
- **Voice Features** - Optional ElevenLabs integration for text-to-speech
- **Persistent Filesystem** - Install packages via chat, they survive restarts
- **Secure** - Automatic IP restrictions + HTTPS-only + daily VM backups
- **One-Click Deploy** - No coding or DevOps knowledge required
- **Extensible** - GitHub, Notion, and webhook integrations available

> **Known Issue:** Control UI WebSocket may disconnect periodically due to OpenClaw bug #7384. **Your bots work perfectly** - only the web UI is affected. See [docs/KNOWN_ISSUES.md](docs/KNOWN_ISSUES.md) for details.

## Quick Start

### Prerequisites

You'll need:

1. **Azure Account** ([sign up free](https://azure.microsoft.com/free))
2. **Messaging Platform Token** - Choose at least one:
   - **Discord Bot Token** ([setup guide](#discord-setup))
   - **Telegram Bot Token** ([setup guide](#telegram-setup))
   - **Slack Bot Token** (see documentation)
   - **WhatsApp Business Token** (see documentation)
3. **Anthropic API Key** ([get yours here](https://console.anthropic.com)) - **Required**

### Optional Enhancements

- **OpenAI API Key** - For GPT models and image generation
- **ElevenLabs API Key** - For text-to-speech and voice cloning
- **GitHub Token** - For repository interactions
- **Notion API Key** - For workspace integrations
- **Groq API Key** - For fast AI inference
- **Cohere API Key** - For additional AI models
- **Brave Search API** - For enhanced web search

### Deploy to Azure

**Option 1: One-Click Deploy (Easiest)**

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Faerolalit%2Fopenclaw-azure%2Fmain%2Fdeploy%2Fazuredeploy.json" target="_blank"><img src="https://aka.ms/deploytoazurebutton" /></a>

**Option 2: CLI Deploy (For Developers)**

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
│   ├── TROUBLESHOOTING.md    # Troubleshooting guide
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

### Discord Setup

1. **Create a Discord Application**
   - Go to [Discord Developer Portal](https://discord.com/developers/applications)
   - Click "New Application"
   - Give it a name (e.g., "My OpenClaw Assistant")

2. **Create a Bot**
   - Go to "Bot" tab
   - Click "Add Bot"
   - Under "Token" section, click "Copy"
   - **Save this token** - you'll need it for deployment

3. **Set Permissions**
   - Go to "OAuth2" > "URL Generator"
   - Select scopes: `bot`, `applications.commands`
   - Select permissions: `Send Messages`, `Read Message History`, `Use Slash Commands`
   - Copy the generated URL and open it to add the bot to your Discord server

### Telegram Setup (Alternative to Discord)

**Easier setup - recommended for beginners!**

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

4. **Configure Privacy (Important!)**
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

Estimated monthly costs (US East region):

| Component          | Cost        | Description                      |
| ------------------ | ----------- | -------------------------------- |
| VM (Standard_B2s)  | $35-40      | 2 vCPU, 4 GB RAM, 30 GB SSD      |
| Storage Account    | $5-10       | Azure Files (100 GB)             |
| VM Backup          | $5-10       | Daily backups (incremental)      |
| Public IP          | $3-4        | Static IP with DNS               |
| **Total**          | **~$48-64** | Varies by VM size and storage    |

**Cost Tips:**
- Use Standard_B1s for testing (~$10/month)
- Enable auto-shutdown for dev environments (saves ~50%)
- Reduce storage quota (10 GB instead of 100 GB)
- Use 7-day backup retention instead of 30 days

---

## Deployment Parameters

The deployment form is organized into clear sections:

### Bot Configuration

| Parameter          | Description                          | Example           |
| ------------------ | ------------------------------------ | ----------------- |
| **App Name**       | Short name for your bot (3-12 chars) | `mybot`           |
| **Confirm Tokens** | Required safety check                | Check this box    |

### Messaging Platform Tokens (At least one required)

| Parameter          | Description                   | Example            |
| ------------------ | ----------------------------- | ------------------ |
| **Discord Token**  | From Discord Developer Portal | `MTEyMz...`        |
| **Telegram Token** | From Telegram @BotFather      | `123456789:ABC...` |
| **Slack Token**    | From Slack app (optional)     | `xoxb-...`         |
| **WhatsApp Token** | Business API token (optional) | Various formats    |

### AI/LLM API Keys

| Parameter         | Description                           | Example            |
| ----------------- | ------------------------------------- | ------------------ |
| **Anthropic Key** | **REQUIRED** - From Anthropic Console | `sk-ant-api03-...` |
| **OpenAI Key**    | Optional - For GPT models             | `sk-...`           |
| **Groq Key**      | Optional - For fast inference         | `gsk_...`          |
| **Cohere Key**    | Optional - Additional AI models       | Various formats    |

### External Service Tokens (All optional)

| Parameter            | Description             | Example         |
| -------------------- | ----------------------- | --------------- |
| **ElevenLabs Key**   | For text-to-speech      | Various formats |
| **Brave Search Key** | Enhanced web search     | Various formats |
| **GitHub Token**     | Repository interactions | `ghp_...`       |
| **Notion Key**       | Workspace integrations  | `secret_...`    |

### Gateway & Federation (Advanced)

| Parameter          | Description               | Example         |
| ------------------ | ------------------------- | --------------- |
| **Gateway Token**  | Multi-instance federation | Various formats |
| **Webhook Secret** | Incoming webhook auth     | Various formats |

**Important:**

- At least one messaging platform token is required
- Anthropic API key is required and must start with `sk-ant-`
- All other tokens are optional but enable additional features

---

## After Deployment

### Check if it's working

**For Discord:**

1. **Find your bot** in Discord - it should show as "Online"
2. **Send a message** like "Hello!" - it should respond

**For Telegram:**

1. **Open your bot** in Telegram (search for @YourBotName)
2. **Send a message** like "Hello!" - it should respond

**Check logs:**

```bash
az vm run-command invoke \
  --resource-group <your-resource-group> \
  --name <your-vm-name> \
  --command-id RunShellScript \
  --scripts 'journalctl -u openclaw -n 50 --no-pager'
```

### Troubleshooting

**Discord bot appears offline?**

- Wait 5-10 minutes for VM provisioning to complete
- Check VM logs (see above)
- Verify Discord token is correct
- Make sure bot has proper permissions in your Discord server

**Telegram bot doesn't respond?**

- Make sure you disabled "Group Privacy" for your bot (see setup guide)
- Try typing `/start` to your bot first
- Check that the token format is correct (numbers:letters)

**Bot doesn't respond on either platform?**

- Check Anthropic API key is valid
- Check VM logs for errors
- Verify bot tokens are entered correctly

**Form validation errors?**

- **Discord Token**: Should be ~59 characters, starts with `MT` or `MQ`
- **Telegram Token**: Should be ~45 characters, format `123456789:ABCdef...`
- **Slack Token**: Should start with `xoxb-` for bot tokens
- **Anthropic Key**: **REQUIRED** - Must start with `sk-ant-` (api03-, oat01-, etc.)
- **OpenAI Key**: Should start with `sk-` (if provided)
- **Groq Key**: Should start with `gsk_` (if provided)
- **GitHub Token**: Should start with `ghp_` (if provided)
- **Notion Key**: Should start with `secret_` (if provided)
- Must check confirmation box and provide at least one messaging platform token

**Deployment failed?**

- Check all required fields are filled
- **Ensure you provided at least one bot token** (Discord or Telegram)
- Ensure app name is 3-12 characters, letters/numbers only
- Try a different Azure region

For more issues, see the complete **[Troubleshooting Guide](./docs/TROUBLESHOOTING.md)**

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
- **Daily Backups** - Full VM backup including installed packages and secrets

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

Your VM is backed up daily at 2:00 AM UTC. Backups include:
- OS disk with all configurations
- Installed packages
- Secrets in `/etc/openclaw/.env`

To restore: Azure Portal → Recovery Services vaults → [your-vault] → Backup Items → Restore VM

See [docs/VM-DEPLOYMENT.md](docs/VM-DEPLOYMENT.md#backup-and-restore) for details.

---

## Support

- **Troubleshooting**: [docs/TROUBLESHOOTING.md](./docs/TROUBLESHOOTING.md) - Common issues and solutions
- **Deployment Guide**: [docs/VM-DEPLOYMENT.md](./docs/VM-DEPLOYMENT.md) - Detailed deployment docs
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
