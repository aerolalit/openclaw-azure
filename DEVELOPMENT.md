# Development Guide

## Template Validation

This repository includes automated validation to prevent deployment issues.

### Local Validation

**Quick validation:**
```bash
./validate-template.sh
```

**Full linting setup:**
```bash
npm install
npm run lint          # Check JSON + formatting
npm run format        # Auto-fix formatting
```

### What Gets Validated

- ✅ **JSON syntax** - Catches parsing errors
- ✅ **ARM template structure** - Ensures required sections exist  
- ✅ **OpenClaw-specific config** - Verifies startup commands, ports, env vars
- ✅ **Code formatting** - Consistent style with Prettier

### GitHub Actions

Every push to `main` or PR automatically runs:
- JSON syntax validation
- Template structure checks  
- Format validation
- ARM template syntax validation (when Azure secrets are configured)

### Fixing Validation Errors

**JSON syntax errors:**
```bash
# Check what's wrong
node -e "JSON.parse(require('fs').readFileSync('azuredeploy.json', 'utf8'))"

# Auto-format
npm run format
```

**ARM template issues:**
- Use Azure portal "Custom deployment" → "Build your own template" to test
- Check the validation script output for specific errors

## Common Issues

### JSON Parsing Errors
- **Missing commas** between properties
- **Trailing commas** in arrays/objects (not allowed in JSON)
- **Unescaped quotes** in strings
- **Missing quotes** around property names

### OpenClaw Container Issues
- **Startup command:** Must be `["node"]` with args `["dist/index.js"]`
- **Port:** Must be `18789` (not 3000)
- **Env vars:** Use `DISCORD_BOT_TOKEN` (not `DISCORD_TOKEN`)

## Template Updates

When updating `azuredeploy.json`:

1. **Always run validation first:**
   ```bash
   ./validate-template.sh
   ```

2. **Test deploy button:**
   - Push changes to GitHub
   - Wait 1-2 minutes for CDN cache
   - Test the "Deploy to Azure" button

3. **Check container logs:**
   - After deployment, verify container starts without permission errors
   - Logs should show OpenClaw starting on port 18789

## Troubleshooting Azure Deployment

**"JSON parsing error at character X":**
1. Run local validation: `./validate-template.sh`
2. If local validation passes, wait 2-3 minutes for GitHub CDN cache
3. Try deployment again

**"Permission denied" in container logs:**
- Check startup command is `node dist/index.js`
- Verify Azure Container Apps environment variables are set
- Check that required tokens (Anthropic + Discord/Telegram) are provided

**Container won't start:**
- Verify port is 18789 in template
- Check environment variable names match OpenClaw expectations
- Ensure Docker image `ghcr.io/openclaw/openclaw:main` is accessible