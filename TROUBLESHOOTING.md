# 🔧 Troubleshooting Guide

## Common Deployment Issues

### ❌ "Unexpected content after function call" Error

**Error message:**
```
Unexpected content after function call.
Encountered: .//
Context: [steps('basics').//]
```

**Root cause:** JSON syntax error - duplicate keys in ARM template parameters

**Solution:** ✅ **FIXED** - Template now uses valid JSON with unique parameter names

**If you still see this error:**
1. Make sure you're using the latest template version
2. Clear your browser cache and try again
3. Use this direct link to ensure you have the latest version:
   ```
   https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Faerolalit%2Fopenclaw-azure%2Fmain%2Fazuredeploy.json
   ```

### 🔐 Token Validation Issues

**Discord Token:**
- Must start with `MT` or `MQ`
- Should be approximately 59 characters
- Get from [Discord Developer Portal](https://discord.com/developers/applications)

**Telegram Token:**
- Format: `123456789:ABCdef...` (numbers:letters)
- Get from [@BotFather](https://t.me/botfather) on Telegram

**Anthropic API Key:**
- Must start with `sk-ant-`
- Various formats: `sk-ant-api03-...` or `sk-ant-oat01-...`
- Get from [Anthropic Console](https://console.anthropic.com)

**Optional Token Formats:**
- **OpenAI**: Must start with `sk-`
- **Slack**: Must start with `xoxb-`
- **GitHub**: Must start with `ghp_`
- **Notion**: Must start with `secret_`
- **Groq**: Must start with `gsk_`

### 🚀 Deployment Fails

**Common causes:**
1. **Missing required tokens** - At least one messaging platform token required
2. **Invalid token format** - Check format requirements above  
3. **Confirmation not checked** - Must check the confirmation checkbox
4. **App name issues** - Must be 3-12 characters, letters and numbers only
5. **Resource limits** - Try a different Azure region

**Quick fixes:**
1. Double-check all required fields
2. Verify token formats match requirements
3. Try deployment in different Azure region
4. Use shorter app name if validation fails

### 🤖 Bot Not Responding

**Discord:**
- Wait 2-3 minutes for container startup
- Check bot shows as "Online" in Discord
- Verify bot has proper permissions in server
- Try sending "Hello!" in a channel the bot can see

**Telegram:**
- Make sure "Group Privacy" is disabled for your bot
- Try typing `/start` to your bot first
- Check bot username ends with "bot"

**General:**
- Check Container App logs in Azure Portal
- Verify Anthropic API key is working
- Ensure internet connectivity for the container

### 📋 Form Validation Errors

**"Please enter a value" errors:**
- All fields with red asterisks (*) are required
- At least one messaging platform token must be provided
- Anthropic API key is always required

**"Invalid format" errors:**
- Check token format requirements in sections above
- Remove any extra spaces or characters
- Verify you copied the entire token

### 🔍 Getting Help

**Logs and Diagnostics:**
1. Go to Azure Portal → Resource Groups → Your app name
2. Click on the Container App (ends with `-app`)
3. Go to "Monitoring" → "Log stream" 
4. Look for error messages or startup logs

**Support Channels:**
- 🐛 **Bug Reports**: [GitHub Issues](https://github.com/aerolalit/openclaw-azure/issues)
- 💬 **Questions**: [GitHub Discussions](https://github.com/aerolalit/openclaw-azure/discussions)
- 📖 **Documentation**: [README.md](./README.md)

## FAQ

**Q: Can I use both Discord and Telegram?**
A: Yes! Provide both tokens and your bot will work on both platforms.

**Q: What if I don't have an Anthropic API key?**
A: The Anthropic API key is required. Sign up at [console.anthropic.com](https://console.anthropic.com) - they offer free credits.

**Q: Can I update my bot after deployment?**
A: Yes, redeploy with the same parameters to get updates. Your data will be preserved.

**Q: How much will this cost?**
A: Approximately $20-30/month for typical usage. Actual costs depend on usage and Azure region.

**Q: Can I use custom AI models?**
A: The template supports Anthropic (required), OpenAI, Groq, and Cohere. Add your API keys during deployment.

---

*Keep this guide handy for quick troubleshooting!*