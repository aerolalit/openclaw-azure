# Getting Started with OpenClaw Azure

Welcome! This guide will help you deploy your own OpenClaw AI assistant to Azure in just a few minutes.

## Before You Begin

You'll need:

1. **Azure account** with an active subscription
2. **Bot token** - Choose one:
   - **Discord bot token** - [Get one here](get-discord-token.md) OR
   - **Telegram bot token** - [Get one here](get-telegram-token.md)
3. **Anthropic API key** - [Get one here](get-anthropic-key.md)

## Step 1: Open Azure Portal

Click the big blue button on our main page:

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Faerolalit%2Fopenclaw-azure%2Fmain%2Fdeploy%2Fazuredeploy.json)

This will take you to the Azure portal deployment page.

## Step 2: Fill in the Details

You'll see a form with several fields:

### Required Fields

**Subscription**: Choose your Azure subscription (usually there's only one)

**Resource Group**:
- Select "Create new"
- Name it something like `openclaw-rg`

**Region**: Choose a location near you:
- `East US` for US East Coast
- `West Europe` for Europe
- `Southeast Asia` for Asia-Pacific

**App Name**: Give your OpenClaw a unique name (letters and numbers only, no spaces)
- Example: `myclaw2024`
- This will be part of your app's URL

**Discord Bot Token**: Paste the token you got from Discord (starts with `MT...`) - leave empty if using Telegram only

**Telegram Bot Token**: Paste the token you got from @BotFather (like `123456789:ABC...`) - leave empty if using Discord only

**Anthropic API Key**: Paste your Claude API key (starts with `sk-ant-...`)

**Allowed IP Addresses**: Enter your public IP address for security. Visit https://api.ipify.org to find it.

**Important:** You must provide at least one bot token (Discord OR Telegram). You can also provide both if you want your bot on both platforms!

## Step 3: Review and Deploy

1. Click **"Review + create"** at the bottom
2. Azure will validate your settings (should show green checkmarks)
3. Click **"Create"** to start deployment

## Step 4: Wait for Deployment

The deployment takes about 10-15 minutes. The VM needs to:
- Provision the virtual machine
- Install Node.js and OpenClaw
- Set up HTTPS with Caddy
- Configure backups

Perfect time to grab a coffee!

## Step 5: Access Your OpenClaw

Once deployment completes:

1. Click **"Go to resource group"**
2. Click on **"Outputs"** in the deployment
3. Find the **Control UI URL** - that's your OpenClaw!
4. Copy the **Gateway Token** to access the Control UI

## Step 6: Test Your OpenClaw

**If you used Discord:**
1. Go to your Discord server
2. Type a message mentioning your bot: `@YourBotName hello`
3. Your OpenClaw should respond!

**If you used Telegram:**
1. Open Telegram and search for your bot: `@YourBotName`
2. Type a message like "Hello!"
3. Your OpenClaw should respond!

## What If Something Goes Wrong?

- Check our [Troubleshooting Guide](troubleshooting.md)
- [Open a GitHub issue](https://github.com/aerolalit/openclaw-azure/issues)
- Make sure your bot tokens and Anthropic key are correct

## Next Steps

- Invite your OpenClaw to more Discord servers
- Ask the bot to install packages: "install pandas", "install ffmpeg"
- Explore what your AI assistant can do
- Check the [Azure portal](https://portal.azure.com) to monitor costs

## Cost Management

Your OpenClaw will cost approximately $43-54/month. To monitor costs:

1. Go to [Azure Cost Management](https://portal.azure.com/#view/Microsoft_Azure_CostManagement/Menu/~/costanalysis)
2. Select your subscription
3. Filter by your resource group name

**Cost saving tip:** Use `Standard_B1s` VM size for testing (~$10/month).

---

**Congratulations!** You now have your own AI assistant running on Azure!
