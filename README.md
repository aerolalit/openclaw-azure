# 🚀 OpenClaw Azure

**One-click deployment of your personal AI assistant to Azure**

Deploy your own private OpenClaw AI assistant powered by Anthropic Claude on Azure Container Apps. Perfect for non-technical users who want their own AI assistant without the complexity.

## ✨ What You Get

- 🤖 **Private Discord Bot** powered by Claude AI
- 🔒 **Secure** - Your API keys stored in Azure Key Vault
- 💰 **Cost-Optimized** - Approximately $20-30/month
- ⚡ **One-Click Deploy** - No coding or DevOps knowledge required
- 📊 **Persistent Storage** - Your conversations and data are saved

## 🎯 Quick Start

### Prerequisites

You'll need:
1. **Azure Account** ([sign up free](https://azure.microsoft.com/free))
2. **Discord Bot Token** ([setup guide](#discord-setup))
3. **Anthropic API Key** ([get yours here](https://console.anthropic.com))

### Deploy to Azure

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Faerolalit%2Fopenclaw-azure%2Fmain%2Fazuredeploy.json)

**That's it!** 🎉

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

### Anthropic API Key

1. Go to [Anthropic Console](https://console.anthropic.com)
2. Sign up/Sign in
3. Go to "API Keys" section
4. Click "Create Key"
5. **Save this key** - you'll need it for deployment

---

## 💰 Cost Breakdown

Estimated monthly costs (US East region):

| Component | Cost | Description |
|-----------|------|-------------|
| Container Apps | $15-25 | Main application hosting |
| Storage Account | $1-2 | Bot workspace and files |
| Key Vault | $1 | Secure secret storage |
| Log Analytics | $2-3 | Monitoring and logs |
| **Total** | **~$20-30** | Varies by usage |

💡 **Cost Tips:**
- Use 7-day log retention for lower costs
- Choose 1 CPU / 2GB memory for light usage
- Monitor usage in Azure Portal

---

## 🔧 Deployment Parameters

| Parameter | Description | Example |
|-----------|-------------|---------|
| **App Name** | Short name for your bot (3-12 chars) | `mybot` |
| **Discord Token** | From Discord Developer Portal | `MTEyMz...` |
| **Anthropic Key** | From Anthropic Console | `sk-ant-api-...` |
| **CPU** | Container CPU allocation | `1.0` (recommended) |
| **Memory** | Container memory allocation | `2Gi` (recommended) |
| **Log Retention** | How long to keep logs | `30` days |

---

## 📖 After Deployment

### Check if it's working
1. **Find your bot** in Discord - it should show as "Online"
2. **Send a message** like "Hello!" - it should respond
3. **Check logs** using the Container App URL from deployment outputs

### Troubleshooting

**Bot appears offline?**
- Wait 2-3 minutes for startup
- Check Container App logs in Azure Portal
- Verify Discord token is correct

**Bot doesn't respond?**
- Check Anthropic API key is valid
- Verify bot permissions in Discord
- Check Application logs for errors

**Deployment failed?**
- Check all required fields are filled
- Ensure app name is 3-12 characters, letters/numbers only
- Try a different Azure region

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

---

## 🤝 Support

- 🐛 **Bug Reports**: [GitHub Issues](https://github.com/aerolalit/openclaw-azure/issues)
- 💬 **Questions**: [GitHub Discussions](https://github.com/aerolalit/openclaw-azure/discussions)
- 📖 **Documentation**: [Wiki](https://github.com/aerolalit/openclaw-azure/wiki)

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

*Want to make AI assistants accessible to everyone, not just developers.*