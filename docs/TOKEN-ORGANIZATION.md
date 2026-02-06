# Token Organization Guide

This document explains how tokens and API keys are organized in the OpenClaw Azure deployment template.

## Token Groups

### Bot Configuration

- **appName**: Your bot's unique identifier (3-12 chars, letters and numbers only)

### Required Tokens

- **anthropicApiKey**: **REQUIRED** - Claude API key (starts with `sk-ant-`)
- **telegramBotToken**: Telegram bot token (format: `123456789:ABC...`)

### Optional Configuration

- **telegramUserId**: Your Telegram numeric user ID (enables immediate bot pairing without manual setup)

### Infrastructure Settings

- **location**: Azure region (e.g., `westeurope`, `eastus`)
- **allowedIpAddresses**: IP addresses allowed to access the VM (auto-detected during CLI deployment)
- **vmSize**: VM size (default: `Standard_B1ms`)
- **osDiskSizeGB**: OS disk size (default: 30 GB)
- **enableBackup**: Enable daily VM backups (default: false)
- **backupFrequency**: Backup frequency - Daily or Weekly (default: Daily)
- **backupRetentionDays**: Backup retention - 7, 14, or 30 days (default: 7)

### Auto-Generated (Optional Override)

- **gatewayToken**: Auto-generated access token for the Control UI (random by default, can be overridden via CLI)
- **adminPassword**: Auto-generated VM admin password for Serial Console emergency access (random by default, can be overridden via CLI)

## Token Validation

### Required

1. **Anthropic API key** (must start with `sk-ant-`)
2. **Telegram bot token** (format: `123456789:ABC...`)

### Format Validation

- **Telegram**: Format `123456789:ABC...`
- **Anthropic**: Must start with `sk-ant-`

## Security Notes

- All tokens stored on VM at `/etc/openclaw/.env`
- VM disk encrypted at rest
- IP restrictions prevent unauthorized access
- HTTPS-only access via Caddy reverse proxy
- VM backups include secrets when enabled (encrypted)
- `parameters.json` is gitignored (never commit secrets)
