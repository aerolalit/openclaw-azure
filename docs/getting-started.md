# Getting Started with OpenClaw Azure

Welcome! This guide will help you deploy your own OpenClaw AI assistant to Azure in just a few minutes.

## Before You Begin

You'll need:

1. **Azure account** with an active subscription
2. **Discord bot token** - [Get one here](get-discord-token.md)
3. **Anthropic API key** - [Get one here](get-anthropic-key.md)

## Step 1: Open Azure Portal

Click the big blue button on our main page:

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Faerolalit%2Fopenclaw-azure%2Fmain%2Fazuredeploy.json)

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

**Discord Bot Token**: Paste the token you got from Discord (starts with `MT...`)

**Anthropic API Key**: Paste your Claude API key (starts with `sk-ant-...`)

### Optional Fields (you can leave these as default)

**Container CPU**: `1.0` (good for most users)
**Container Memory**: `2Gi` (good for most users)

## Step 3: Review and Deploy

1. Click **"Review + create"** at the bottom
2. Azure will validate your settings (should show green checkmarks)
3. Click **"Create"** to start deployment

## Step 4: Wait for Deployment

The deployment takes about 5-10 minutes. You'll see a progress screen.

☕ Perfect time to grab a coffee!

## Step 5: Get Your OpenClaw URL

Once deployment completes:

1. Click **"Go to resource group"**
2. Find the Container App (has a whale icon 🐳)
3. Click on it
4. Look for **"Application Url"** - that's your OpenClaw!

## Step 6: Test Your OpenClaw

1. Go to your Discord server
2. Type a message mentioning your bot: `@YourBotName hello`
3. Your OpenClaw should respond! 🎉

## What If Something Goes Wrong?

- Check our [Troubleshooting Guide](troubleshooting.md)
- [Open a GitHub issue](https://github.com/aerolalit/openclaw-azure/issues)
- Make sure your Discord token and Anthropic key are correct

## Next Steps

- Invite your OpenClaw to more Discord servers
- Explore what your AI assistant can do
- Check the [Azure portal](https://portal.azure.com) to monitor costs

## Cost Management

Your OpenClaw will cost approximately $20-30/month. To monitor costs:

1. Go to [Azure Cost Management](https://portal.azure.com/#view/Microsoft_Azure_CostManagement/Menu/~/costanalysis)
2. Select your subscription
3. Filter by your resource group name

---

**Congratulations!** 🎉 You now have your own AI assistant running on Azure!