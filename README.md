# 🚀 OpenClaw Azure

**One-click deployment of your personal AI assistant to Azure**

Deploy your own private OpenClaw AI assistant powered by Anthropic Claude on Azure Container Apps. Perfect for non-technical users who want their own AI assistant without the complexity.

## ✨ What You Get

- 🤖 **Private AI Bot** for Discord, Telegram, Slack, or WhatsApp powered by Claude AI
- 🧠 **Multi-AI Support** - Anthropic Claude (required) + optional OpenAI, Groq, Cohere
- 🎙️ **Voice Features** - Optional ElevenLabs integration for text-to-speech
- 🔒 **Secure** - Automatic IP restrictions + Azure Key Vault + HTTPS-only access
- 💰 **Cost-Optimized** - Approximately $20-30/month
- ⚡ **One-Click Deploy** - No coding or DevOps knowledge required
- 📊 **Persistent Storage** - Your conversations and data are saved
- 🔗 **Extensible** - GitHub, Notion, and webhook integrations available

> ⚠️ **Known Issue:** Control UI WebSocket may disconnect periodically due to OpenClaw bug #7384. **Your bots work perfectly** - only the web UI is affected. See [docs/KNOWN_ISSUES.md](docs/KNOWN_ISSUES.md) for details.

## 📁 Repository Structure

```
openclaw-azure/
├── deploy/                    # Deployment files
│   ├── azuredeploy.json      # ARM template
│   ├── deploy.sh             # Deployment script
│   ├── parameters.json.example # Configuration template
│   └── validate-template.sh  # Validation utility
│
├── docs/                      # Documentation
│   ├── DEPLOYMENT.md         # Deployment guide
│   ├── docs/TROUBLESHOOTING.md    # Troubleshooting guide
│   ├── CONTRIBUTING.md       # Contribution guidelines
│   ├── DEVELOPMENT.md        # Developer guide
│   └── guides/               # Step-by-step guides
│
├── scripts/                   # Utility scripts
│   └── cleanup-deployments.sh # Clean up test deployments
│
└── README.md                  # You are here!
```

## 🎯 Quick Start

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

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Faerolalit%2Fopenclaw-azure%2Fmain%2Fdeploy%2Fazuredeploy.json%3Fv%3D2" target="_blank"><img src="https://aka.ms/deploytoazurebutton" /></a>

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

**That's it!** 🎉

> 📖 **For detailed deployment instructions**, see [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md)

---

## 📋 Setup Guides

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

## 💰 Cost Breakdown

Estimated monthly costs (US East region):

| Component       | Cost        | Description              |
| --------------- | ----------- | ------------------------ |
| Container Apps  | $15-25      | Main application hosting |
| Storage Account | $1-2        | Bot workspace and files  |
| Key Vault       | $1          | Secure secret storage    |
| Log Analytics   | $2-3        | Monitoring and logs      |
| **Total**       | **~$20-30** | Varies by usage          |

💡 **Cost Tips:**

- Use 7-day log retention for lower costs
- Choose 1 CPU / 2GB memory for light usage
- Monitor usage in Azure Portal

---

## 🔧 Deployment Parameters

The deployment form is now organized into clear sections:

### 🤖 Bot Configuration

| Parameter          | Description                          | Example           |
| ------------------ | ------------------------------------ | ----------------- |
| **App Name**       | Short name for your bot (3-12 chars) | `mybot`           |
| **Confirm Tokens** | Required safety check                | ✅ Check this box |

### 🤝 Messaging Platform Tokens (At least one required)

| Parameter          | Description                   | Example            |
| ------------------ | ----------------------------- | ------------------ |
| **Discord Token**  | From Discord Developer Portal | `MTEyMz...`        |
| **Telegram Token** | From Telegram @BotFather      | `123456789:ABC...` |
| **Slack Token**    | From Slack app (optional)     | `xoxb-...`         |
| **WhatsApp Token** | Business API token (optional) | Various formats    |

### 🧠 AI/LLM API Keys

| Parameter         | Description                           | Example            |
| ----------------- | ------------------------------------- | ------------------ |
| **Anthropic Key** | **REQUIRED** - From Anthropic Console | `sk-ant-api03-...` |
| **OpenAI Key**    | Optional - For GPT models             | `sk-...`           |
| **Groq Key**      | Optional - For fast inference         | `gsk_...`          |
| **Cohere Key**    | Optional - Additional AI models       | Various formats    |

### 🌐 External Service Tokens (All optional)

| Parameter            | Description             | Example         |
| -------------------- | ----------------------- | --------------- |
| **ElevenLabs Key**   | For text-to-speech      | Various formats |
| **Brave Search Key** | Enhanced web search     | Various formats |
| **GitHub Token**     | Repository interactions | `ghp_...`       |
| **Notion Key**       | Workspace integrations  | `secret_...`    |

### 🔗 Gateway & Federation (Advanced)

| Parameter          | Description               | Example         |
| ------------------ | ------------------------- | --------------- |
| **Gateway Token**  | Multi-instance federation | Various formats |
| **Webhook Secret** | Incoming webhook auth     | Various formats |

### ⚙️ Infrastructure Settings

| Parameter         | Description                 | Example             |
| ----------------- | --------------------------- | ------------------- |
| **CPU**           | Container CPU allocation    | `1.0` (recommended) |
| **Memory**        | Container memory allocation | `2Gi` (recommended) |
| **Log Retention** | How long to keep logs       | `30` days           |

**⚠️ Important:**

- At least one messaging platform token is required
- Anthropic API key is required and must start with `sk-ant-`
- All other tokens are optional but enable additional features

---

## 📖 After Deployment

### Check if it's working

**For Discord:**

1. **Find your bot** in Discord - it should show as "Online"
2. **Send a message** like "Hello!" - it should respond

**For Telegram:**

1. **Open your bot** in Telegram (search for @YourBotName)
2. **Send a message** like "Hello!" - it should respond

**Both platforms:** 3. **Check logs** using the Container App URL from deployment outputs

### Troubleshooting

**Discord bot appears offline?**

- Wait 2-3 minutes for startup
- Check Container App logs in Azure Portal
- Verify Discord token is correct
- Make sure bot has proper permissions in your Discord server

**Telegram bot doesn't respond?**

- Make sure you disabled "Group Privacy" for your bot (see setup guide)
- Try typing `/start` to your bot first
- Check that the token format is correct (numbers:letters)

**Bot doesn't respond on either platform?**

- Check Anthropic API key is valid
- Check Container App logs for errors
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
- **⚠️ Must check confirmation box** and provide at least one messaging platform token
- If you see validation errors, check the "Errors" panel on the right →

**Deployment failed?**

- Check all required fields are filled
- **Ensure you provided at least one bot token** (Discord or Telegram)
- Ensure app name is 3-12 characters, letters/numbers only
- Try a different Azure region

**"Unexpected content after function call" error?**

- ✅ **FIXED** - This was a JSON syntax issue that has been resolved
- Make sure you're using the latest template (clear browser cache)
- See [docs/TROUBLESHOOTING.md](./docs/TROUBLESHOOTING.md) for details

For more issues, see the complete **[🔧 Troubleshooting Guide](./docs/TROUBLESHOOTING.md)**

---

## 🔒 Security Features

### Automatic IP Restriction (Defense-in-Depth)

Your deployment includes **automatic IP restriction** for enhanced security:

✅ **Auto-detected during deployment** - Your public IP is automatically added as the only allowed IP
✅ **Defense-in-depth** - Gateway token + IP restriction (two factors required)
✅ **Network-level protection** - Blocks unauthorized access before reaching the application
✅ **90% reduction** in attack surface for remote attackers

**How it works:**

1. **CLI Deployment** (`./deploy/deploy.sh`):
   - Script auto-detects your public IP
   - Configures Container App to only allow your IP
   - Shows your IP in deployment output

2. **Azure Portal Deployment**:
   - Form prompts you to visit https://api.ipify.org
   - Copy your IP and enter as `["203.0.113.45/32"]`
   - Deployment requires at least one IP for security

**What this protects against:**
- ❌ Leaked gateway token in logs/screenshots → Attacker blocked (wrong IP)
- ❌ Accidentally shared credentials → Recipient blocked (wrong IP)
- ❌ Brute force attacks → Blocked at network layer (wrong IP)
- ❌ Unauthorized access from compromised networks → Blocked (wrong IP)

### Managing IP Restrictions

**When your IP changes (home internet, VPN, etc.):**

**Option 1 - Azure Portal:**
```
Portal → Container Apps → [your app] → Ingress → IP Security Restrictions → Add
```

**Option 2 - Azure CLI (Quick):**
```bash
az containerapp update \
  --name openclaw-abc123 \
  --resource-group openclaw-rg \
  --set properties.configuration.ingress.ipSecurityRestrictions="[{\"name\":\"CurrentIP\",\"ipAddressRange\":\"$(curl -s https://api.ipify.org)/32\",\"action\":\"Allow\"}]"
```

**Option 3 - Add team member:**
```bash
az containerapp ingress access-restriction set \
  --name openclaw-abc123 \
  --resource-group openclaw-rg \
  --rule-name "AllowColleague" \
  --ip-address "198.51.100.50/32" \
  --action Allow
```

📖 For complete IP restriction management guide, see [docs/DEPLOYMENT.md#ip-restrictions-security-feature](docs/DEPLOYMENT.md#ip-restrictions-security-feature)

### Additional Security Layers

✅ **Azure Key Vault** - All API keys and tokens encrypted at rest
✅ **HTTPS-Only** - All traffic encrypted in transit
✅ **Managed Identity** - No hardcoded credentials, Azure handles authentication
✅ **Secret References** - Tokens passed via secure references, never in logs
✅ **Regular Rotation** - Easy to rotate tokens via Azure Portal

**Security Note:** Due to OpenClaw bug #7384, device pairing is disabled (`dangerouslyDisableDeviceAuth: true`). IP restrictions mitigate this by adding network-level access control. Once OpenClaw fixes the bug, device pairing can be re-enabled for additional security.

---

## 🛠 Advanced Usage

### Accessing Your Bot's Web Interface

After deployment, you'll get a Container App URL. This provides:

- Real-time logs
- Health status
- Performance metrics

### Updating Your Bot

- Redeploy with the same parameters to get latest updates
- Your data and configuration will be preserved

### Backup and Restore

Your bot's data is stored in Azure Storage. To backup:

1. Download files from the storage account
2. Redeploy if needed and upload files back

### Token Organization

The deployment template now features improved organization:

- **Visual grouping** with clear sections and emoji headers
- **Enhanced validation** with format checking for all token types
- **Comprehensive support** for 10+ services out of the box
- **Security-first design** with all secrets stored in Azure Key Vault
- **Future-proof structure** for easy addition of new integrations

See [TOKEN-ORGANIZATION.md](./TOKEN-ORGANIZATION.md) for detailed documentation.

---

## 🤝 Support

- 🔧 **Troubleshooting**: [docs/TROUBLESHOOTING.md](./docs/TROUBLESHOOTING.md) - Common issues and solutions
- 🐛 **Bug Reports**: [GitHub Issues](https://github.com/aerolalit/openclaw-azure/issues)
- 💬 **Questions**: [GitHub Discussions](https://github.com/aerolalit/openclaw-azure/discussions)
- 📖 **Documentation**: [TOKEN-ORGANIZATION.md](./TOKEN-ORGANIZATION.md) - Token guide

---

## 📄 License

MIT License - feel free to fork and customize!

## ⭐ Contributing

We welcome contributions! Whether it's:

- 🐛 Bug fixes
- 📖 Documentation improvements
- ✨ New features
- 💡 Ideas and suggestions

---

**Made with ❤️ for the AI community**

_Want to make AI assistants accessible to everyone, not just developers._
