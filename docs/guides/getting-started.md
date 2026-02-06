# Getting Started with OpenClaw Azure

Welcome! This guide will help you deploy your own OpenClaw AI assistant to Azure in just a few minutes.

## Before You Begin

You'll need:

1. **Azure account** with an active subscription
2. **Telegram bot token** - [Get one here](get-telegram-token.md)
3. **Anthropic API key** - [Get one here](get-anthropic-key.md)

## Step 1: Open Azure Portal

Click the big blue button on our main page:

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Faerolalit%2Fopenclaw-azure%2Fmain%2Fdeploy%2Fazuredeploy.json/createUIDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2Faerolalit%2Fopenclaw-azure%2Fmain%2Fdeploy%2FcreateUiDefinition.json)

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

**Telegram Bot Token**: Paste the token you got from @BotFather (like `123456789:ABC...`)

**Anthropic API Key**: Paste your Claude API key (starts with `sk-ant-...`)

**Allowed IP Addresses**: Enter your public IP address for security. Visit https://api.ipify.org to find it.

## Step 3: Review and Deploy

1. Click **"Review + create"** at the bottom
2. Azure will validate your settings (should show green checkmarks)
3. Click **"Create"** to start deployment

## Step 4: Wait for Deployment

The deployment takes about 10-15 minutes. The VM needs to:

- Provision the virtual machine
- Install Node.js and OpenClaw
- Set up HTTPS with Caddy
- Start the OpenClaw service

Perfect time to grab a coffee!

## Step 5: Access Your OpenClaw

Once deployment completes:

1. Click **"Go to resource group"**
2. Click on **"Outputs"** in the deployment
3. Find the **Control UI URL** - that's your OpenClaw!
4. The **Gateway Token** is included in the URL (auto-generated)

## Step 6: Test Your OpenClaw

1. Open Telegram and search for your bot: `@YourBotName`
2. Type a message like "Hello!"
3. Your OpenClaw should respond!

## What If Something Goes Wrong?

- Check our [Troubleshooting Guide](../VM-DEPLOYMENT.md#troubleshooting)
- [Open a GitHub issue](https://github.com/aerolalit/openclaw-azure/issues)
- Make sure your Telegram bot token and Anthropic key are correct

## Next Steps

- Ask the bot to install packages: "install pandas", "install ffmpeg"
- Open the Control UI to manage your bot
- Explore what your AI assistant can do
- Check the [Azure portal](https://portal.azure.com) to monitor costs

## Cost Management

Your OpenClaw will cost approximately $22-30/month (Standard_B1ms default). To monitor costs:

1. Go to [Azure Cost Management](https://portal.azure.com/#view/Microsoft_Azure_CostManagement/Menu/~/costanalysis)
2. Select your subscription
3. Filter by your resource group name

**Cost saving tip:** Use `Standard_B1s` VM size for testing (~$10/month).

---

**Congratulations!** You now have your own AI assistant running on Azure!
