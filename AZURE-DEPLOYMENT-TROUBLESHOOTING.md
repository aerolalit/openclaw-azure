# Azure Deployment Troubleshooting

## Current Issue: "JSON parsing error at character position 1021"

If you're still seeing this error after our fixes, it's likely due to **Azure CDN caching** the old template version.

### ✅ **Template is Actually Fixed**
- JSON syntax is valid (verified locally)
- All OpenClaw configuration issues resolved
- GitHub Actions validation passes

### 🕒 **Cache Issue Workaround**

**Option 1: Wait for cache refresh (2-5 minutes)**
The Azure portal caches raw GitHub files. Wait a few minutes and try again.

**Option 2: Force cache bypass**
Instead of using the deploy button, manually deploy:

1. Go to Azure Portal → Create Resource → Template Deployment
2. Choose "Build your own template in the editor" 
3. Copy-paste the entire content from: https://raw.githubusercontent.com/aerolalit/openclaw-azure/main/azuredeploy.json
4. Click "Save" and proceed with deployment

**Option 3: Use Azure CLI**
```bash
# Download latest template
curl -o azuredeploy.json https://raw.githubusercontent.com/aerolalit/openclaw-azure/main/azuredeploy.json

# Deploy directly
az deployment group create \
  --resource-group "openclaw-rg" \
  --template-file azuredeploy.json \
  --parameters appName="myopenclaw" \
               anthropicApiKey="sk-ant-your-key" \
               discordBotToken="your-discord-token"
```

### 🔍 **Verify Template is Fixed**

Run our validation script locally:
```bash
# Clone repo
git clone https://github.com/aerolalit/openclaw-azure.git
cd openclaw-azure

# Validate
./validate-template.sh
```

Should show:
```
✅ JSON syntax is valid
✅ Correct container startup command found  
✅ Correct port configuration (18789)
✅ Correct Discord environment variable name
🎉 Template validation completed successfully!
```

### 🚀 **What's Fixed in the Template**

1. **Container startup**: Now uses `node dist/index.js` instead of non-existent `openclaw` commands
2. **Port**: Changed from 3000 to 18789 (OpenClaw default)
3. **Environment variables**: Uses `DISCORD_BOT_TOKEN` (standard name)
4. **JSON syntax**: No more parsing errors
5. **Validation**: Removed unnecessary confirmation parameter

### ⏭️ **Next Steps After Successful Deployment**

1. **Check container logs** in Azure Portal:
   - Should show OpenClaw starting on port 18789
   - No "permission denied" errors
   - No "openclaw: command not found" errors

2. **Access your OpenClaw**:
   - Use the Container App URL provided in outputs
   - Should see OpenClaw web interface
   - Bot should respond in Discord/Telegram

3. **Monitor costs**:
   - Expected: ~$20-30/month
   - Mostly from Container Apps + Storage

---

**Still having issues?** Open an issue at: https://github.com/aerolalit/openclaw-azure/issues