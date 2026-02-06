# Troubleshooting OpenClaw Azure

Having issues with your OpenClaw deployment? This guide covers the most common problems and their solutions.

## 🚨 Common Deployment Issues

### Deployment Failed - "Resource name already exists"

**Problem**: Azure says your app name is already taken.
**Solution**: 
1. Go back to the deployment form
2. Change your **App Name** to something more unique
3. Try adding numbers or your initials: `myclaw2024-jd`

### Deployment Failed - "Invalid Discord Token"

**Problem**: The Discord token format is incorrect.
**Solution**:
1. Check your token starts with `MT` or `MQ`
2. Make sure you didn't copy extra spaces
3. [Get a new Discord token](get-discord-token.md) if needed

### Deployment Failed - "Invalid Anthropic API Key"

**Problem**: The Anthropic API key format is incorrect.
**Solution**:
1. Check your key starts with `sk-ant-`
2. Make sure you didn't copy extra spaces
3. Verify you have credits in your Anthropic account
4. [Get a new API key](get-anthropic-key.md) if needed

### Deployment Stuck at "Creating resources"

**Problem**: Deployment seems frozen for more than 15 minutes.
**Solution**:
1. Wait up to 30 minutes (Azure can be slow)
2. If still stuck, cancel and retry the deployment
3. Try a different Azure region

## 🤖 Bot Not Responding Issues

### Bot Shows as Offline

**Problem**: Discord bot appears offline in your server.
**Solution**:
1. Check if deployment completed successfully
2. Go to Azure Portal → Resource Groups → Your OpenClaw Container App
3. Check if the container is running (should show "Running" status)
4. If not running, check logs for errors

### Bot Online But Not Responding

**Problem**: Bot shows online but doesn't respond to messages.
**Solution**:
1. Make sure you're mentioning the bot: `@YourBotName hello`
2. Check bot permissions in Discord:
   - Can read messages in the channel
   - Can send messages in the channel
3. Try in a different channel or DM

### Bot Says "I don't have permission"

**Problem**: Bot responds but says it lacks permissions.
**Solution**:
1. Right-click your Discord server name
2. Go to Server Settings → Roles
3. Find your bot's role
4. Give it these permissions:
   - Send Messages ✅
   - Read Message History ✅
   - Add Reactions ✅
   - Attach Files ✅

## 💰 Cost and Billing Issues

### Higher Than Expected Azure Costs

**Problem**: Azure bill is more than $20-30/month.
**Solution**:
1. Go to Azure Cost Management in the portal
2. Check which resources cost the most
3. Consider reducing CPU/Memory if usage is low
4. Ensure you're not running multiple instances

### High Anthropic API Costs

**Problem**: Claude usage charges are unexpectedly high.
**Solution**:
1. Check usage in Anthropic Console → Settings → Usage
2. Set spending limits: Settings → Billing → Spending Limits
3. Monitor for unusually long conversations
4. Consider using Claude more efficiently

## 🔧 Container App Issues

### App Keeps Restarting

**Problem**: Container shows "Restarting" status repeatedly.
**Solution**:
1. Go to Container App → Monitoring → Log stream
2. Look for error messages in the logs
3. Common issues:
   - Invalid API keys (check Key Vault)
   - Network connectivity problems
   - Memory issues (try increasing memory)

### Can't Access App URL

**Problem**: The Container App URL shows an error page.
**Solution**:
1. Check if container is running
2. Look at logs for startup errors
3. Verify all secrets are properly stored in Key Vault
4. Try restarting the container app

## 🔑 Key Vault and Secrets Issues

### Secrets Not Loading

**Problem**: App can't read Discord token or API key.
**Solution**:
1. Go to Key Vault in Azure Portal
2. Check if secrets exist: `discord-token`, `anthropic-key`
3. Verify Container App has access to Key Vault
4. Check Container App → Identity → System assigned is enabled

## 📊 Monitoring and Logs

### How to Check Logs

1. Go to Azure Portal
2. Navigate to your Resource Group
3. Click on the Container App
4. Go to **Monitoring** → **Log stream**
5. Look for error messages or clues

### How to Check App Health

1. Container App → **Overview**
2. Check **Status** is "Running"
3. Check **Health** is "Healthy"
4. Look at **CPU** and **Memory** usage

## 🆘 Getting More Help

### Before Opening an Issue

Please collect this information:

1. **Error message** (exact text)
2. **Deployment logs** (from Azure Portal)
3. **Container logs** (if app deployed)
4. **What you were trying to do**
5. **What happened instead**

### Where to Get Help

1. **GitHub Issues**: [Report a bug](https://github.com/aerolalit/openclaw-azure/issues)
2. **Documentation**: Re-read the [Getting Started Guide](getting-started.md)
3. **Azure Support**: For Azure-specific issues

### How to Open a Good Issue

1. Use a clear title: "Deployment fails with invalid token error"
2. Include your environment:
   - Azure region used
   - When the problem started
3. Include logs and error messages
4. Say what you've already tried

## 🔄 Starting Over

### Clean Deployment

If everything is broken and you want to start fresh:

1. Go to Azure Portal → Resource Groups
2. Find your OpenClaw resource group
3. Click **Delete resource group**
4. Wait for deletion to complete
5. Start the deployment process again

**Note**: This will delete all data and backups!

---

**Still need help?** [Open an issue on GitHub](https://github.com/aerolalit/openclaw-azure/issues) with details about your problem.