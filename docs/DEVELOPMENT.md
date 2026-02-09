# Development Guide

## Template Validation

### Local Validation

**Quick JSON check:**

```bash
node -e "JSON.parse(require('fs').readFileSync('deploy/azuredeploy.json', 'utf8'))"
```

**Full linting setup:**

```bash
npm install
npm run lint          # Check JSON + formatting
npm run format        # Auto-fix formatting
```

### What Gets Validated

- **JSON syntax** - Catches parsing errors
- **ARM template structure** - Ensures required sections exist
- **OpenClaw-specific config** - Verifies startup commands, ports, env vars
- **Code formatting** - Consistent style with Prettier

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
node -e "JSON.parse(require('fs').readFileSync('deploy/azuredeploy.json', 'utf8'))"

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

### OpenClaw Docker Issues

- **Port:** OpenClaw listens on `18789`, Caddy proxies HTTPS:443 → localhost:18789
- **Env vars:** Use `DISCORD_BOT_TOKEN` (not `DISCORD_TOKEN`)
- **Config:** Written inline via `printf` in docker run command
- **Secrets:** Loaded via `--env-file /etc/openclaw/.env`

## Template Updates

When updating `azuredeploy.json`:

1. **Always validate JSON first:**

   ```bash
   node -e "JSON.parse(require('fs').readFileSync('deploy/azuredeploy.json', 'utf8'))"
   ```

2. **Test deploy button:**
   - Push changes to GitHub
   - Wait 1-2 minutes for CDN cache
   - Test the "Deploy to Azure" button

3. **Check VM logs after deployment:**
   - Wait for cloud-init to complete (5-10 minutes)
   - Check `docker logs openclaw` for startup errors
   - Verify Caddy is serving HTTPS

## Troubleshooting Azure Deployment

**"JSON parsing error at character X":**

1. Run local validation (see above)
2. If local validation passes, wait 2-3 minutes for GitHub CDN cache
3. Try deployment again

**OpenClaw not starting:**

- Check cloud-init status: `cloud-init status`
- Check Docker container: `docker logs openclaw`
- Verify port 18789 is listening: `ss -tlnp | grep 18789`
- Ensure Docker image `ghcr.io/openclaw/openclaw:main` is accessible

**Caddy not serving HTTPS:**

- Check Caddy status: `systemctl status caddy`
- Check Caddy logs: `journalctl -u caddy -n 50`
- Verify NSG allows port 80 (needed for Let's Encrypt ACME challenge)
- Verify DNS name resolves: `nslookup <vm-dns-name>`
