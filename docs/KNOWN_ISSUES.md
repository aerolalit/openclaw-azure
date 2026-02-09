# Known Issues

This document lists known issues with OpenClaw on Azure and their workarounds.

## Control UI WebSocket Disconnections

**Severity:** Medium
**Affects:** Control UI web interface only
**Platforms Affected:** Discord, Telegram, Slack, WhatsApp bots work normally

### Symptoms

When accessing the OpenClaw Control UI:
- Connection disconnects with `code=1005` after a few seconds
- Need to reconnect frequently
- Gateway token works but connection isn't stable

### Root Cause

OpenClaw has a bug with `trustedProxies` configuration (issue #7384) that prevents it from properly handling connections behind reverse proxies like Caddy.

### Workaround

The template includes a workaround that:
1. Sets `dangerouslyDisableDeviceAuth: true` to bypass device pairing
2. Configures `trustedProxies` (though OpenClaw currently ignores it)
3. Uses `allowInsecureAuth: true` for token-only authentication

This allows the Control UI to work, but connections may still be unstable.

### What Works

**All bot platforms work perfectly:**
- Discord bot
- Telegram bot
- Slack bot
- WhatsApp bot

**Control UI is accessible:**
- Can access with gateway token
- Can configure settings
- Can view status

**What's affected:**
- Control UI WebSocket may disconnect periodically
- Need to refresh/reconnect sometimes

### Long-term Fix

We've reported this bug to the OpenClaw team:
- Issue #7384: trustedProxies not working
- Issue #1679: allowInsecureAuth doesn't work as documented

Once these are fixed in OpenClaw, Azure deployments will have stable Control UI connections.

### Alternative Access

If Control UI disconnects are disruptive:
1. Configure your bots through Discord/Telegram/Slack directly
2. Use the initial deployment outputs to set up channels
3. Bot functionality is not affected by this issue

## Security Implications

Due to the OpenClaw bugs, we had to use `dangerouslyDisableDeviceAuth: true`. This means:

**Original Risk:**
- No device pairing required
- Only gateway token protected access
- Anyone with the gateway token could access from anywhere

**Automatic Mitigations (Now in Place):**
- **IP Restrictions** - Automatically configured during deployment (only your IP allowed)
- **Defense-in-depth** - Gateway token + IP restriction required (two factors)
- **Network-level blocking** - Unauthorized IPs blocked before reaching application
- **90% reduction** in attack surface for remote attackers
- 52-character cryptographically random gateway token
- Secrets stored on VM at `/etc/openclaw/.env` (encrypted at rest)
- HTTPS-only access via Caddy reverse proxy

**How IP Restrictions Work:**
- CLI deployment: Your public IP auto-detected and configured
- Azure Portal deployment: Required to provide at least one IP address
- Can add more IPs post-deployment via Azure Portal or CLI

Even if gateway token leaks (logs, screenshots, etc.), attackers from other IPs are blocked at the network layer.

### Recommended for Production

If using in production:
1. **IP restrictions already applied** - Add team members' IPs as needed
2. Set a custom strong gateway token in parameters (optional, auto-generated is strong)
3. Rotate gateway token regularly
4. Monitor access logs in Azure Portal
5. Use IP ranges for office networks (e.g., `203.0.113.0/24`)

**Managing IP Restrictions:**
- See [VM-DEPLOYMENT.md](VM-DEPLOYMENT.md#2-managing-ip-restrictions) for complete guide
- Portal: Network Security Groups → [your-app]-nsg → Inbound security rules
- CLI: `az network nsg rule create`

## Reporting Issues

Found a new issue?
1. Check [GitHub Issues](https://github.com/aerolalit/openclaw-azure/issues)
2. Open a new issue with:
   - Description of the problem
   - Steps to reproduce
   - Azure region and configuration
   - Logs if available

For OpenClaw bugs:
- Report at [OpenClaw repository](https://github.com/openclaw/openclaw/issues)
