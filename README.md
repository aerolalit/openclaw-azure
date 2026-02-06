# OpenClaw Azure - One-Click Deployment

Deploy your own OpenClaw AI assistant to Azure in minutes!

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Faerolalit%2Fopenclaw-azure%2Fmain%2Fazuredeploy.json)

## 🚀 Quick Start

1. Click the "Deploy to Azure" button above
2. Fill in the required information:
   - **Resource Group**: Create new or select existing
   - **Location**: Choose a region near you
   - **App Name**: Give your OpenClaw a unique name
   - **Discord Bot Token**: [Get from Discord Developer Portal](docs/get-discord-token.md)
   - **Anthropic API Key**: [Get from Anthropic Console](docs/get-anthropic-key.md)
3. Click "Review + create" then "Create"
4. Wait 5-10 minutes for deployment to complete
5. Your OpenClaw is ready! 🎉

## 💰 Cost Estimate

Running OpenClaw costs approximately **$20-30 per month**:
- Container App: ~$15-20/month
- Storage: ~$2-3/month  
- Key Vault: ~$0.03/month
- Monitoring: ~$2-5/month

*Plus your Anthropic API usage (billed separately)*

## 📚 Documentation

- **[Getting Started Guide](docs/getting-started.md)** - Step-by-step with screenshots
- **[Get Discord Token](docs/get-discord-token.md)** - How to create a Discord bot
- **[Get Anthropic Key](docs/get-anthropic-key.md)** - How to get Claude API access
- **[Troubleshooting](docs/troubleshooting.md)** - Common issues and fixes

## 🔧 Advanced Users

If you prefer command-line deployment:

```bash
# Clone this repo
git clone https://github.com/aerolalit/openclaw-azure.git
cd openclaw-azure

# Deploy using Azure CLI
./deploy.sh --name "my-openclaw" --discord-token "YOUR_TOKEN" --anthropic-key "YOUR_KEY"
```

## ✨ Features

- **Secure**: All secrets stored in Azure Key Vault
- **Reliable**: Hosted on Azure Container Apps
- **Backed up**: Automatic daily backups
- **Affordable**: Optimized for cost (~$20-30/month)
- **Isolated**: Your own private instance

## 🏗️ What Gets Created

```
Your Azure Resource Group
├── 🐳 Container App (OpenClaw)
├── 🔑 Key Vault (secrets)
├── 💾 Storage Account (data + backups)
└── 📊 Log Analytics (monitoring)
```

## 🆘 Need Help?

- **Issues**: [Open a GitHub issue](https://github.com/aerolalit/openclaw-azure/issues)
- **Documentation**: Browse the [docs](docs/) folder
- **Community**: Join the OpenClaw community

## 🤝 Contributing

Found a bug? Want to improve the documentation? Pull requests welcome!

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

---

**OpenClaw** - Your personal AI assistant, running on your Azure account.