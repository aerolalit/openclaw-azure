# Token Organization Guide

This document explains how tokens and API keys are organized in the OpenClaw Azure deployment template for better clarity and management.

## Token Groups

### Bot Configuration

- **appName**: Your bot's unique identifier
- **confirmTokensProvided**: Required safety check

### Messaging Platform Tokens

**At least ONE required:**

- **discordBotToken**: Discord bot token (starts with `MT` or `MQ`)
- **telegramBotToken**: Telegram bot token (format: `123456789:ABC...`)
- **slackBotToken**: Slack bot token (starts with `xoxb-`)
- **whatsappToken**: WhatsApp Business API token

### AI/LLM API Keys

**Anthropic required, others optional:**

- **anthropicApiKey**: **REQUIRED** - Claude API key (starts with `sk-ant-`)
- **openaiApiKey**: OpenAI API key for GPT models (starts with `sk-`)
- **groqApiKey**: Groq API key for fast inference (starts with `gsk_`)
- **cohereApiKey**: Cohere API key for additional models

### External Service Tokens

**All optional:**

- **elevenlabsApiKey**: Text-to-speech/voice cloning
- **braveSearchApiKey**: Enhanced web search capabilities
- **githubToken**: Repository interactions (starts with `ghp_`)
- **notionApiKey**: Notion integrations (starts with `secret_`)

### Gateway & Federation Tokens

**Advanced features:**

- **gatewayToken**: Multi-instance federation
- **webhookSecret**: Incoming webhook authentication

### Infrastructure Settings

**Azure deployment config:**

- **location**: Azure region
- **allowedIpAddresses**: IP addresses allowed to access the VM (auto-detected during CLI deployment)

## Token Validation

### Required Tokens

1. **At least one messaging platform token** (Discord OR Telegram OR Slack OR WhatsApp)
2. **Anthropic API key** (must start with `sk-ant-`)
3. **Confirmation checkbox** must be checked

### Format Validation

- **Discord**: Starts with `MT` or `MQ`, ~59 characters
- **Telegram**: Format `123456789:ABC...`
- **Anthropic**: Must start with `sk-ant-`
- **OpenAI**: Must start with `sk-` (if provided)
- **Groq**: Must start with `gsk_` (if provided)
- **GitHub**: Must start with `ghp_` (if provided)
- **Notion**: Must start with `secret_` (if provided)

## Security Notes

- All tokens stored on VM at `/etc/openclaw/.env`
- VM disk encrypted at rest
- IP restrictions prevent unauthorized access
- HTTPS-only access via Caddy reverse proxy
- Daily VM backups include secrets (encrypted)

## Future Extensibility

This structure makes it easy to add new token types:

- New AI providers → Add to "AI/LLM API Keys" section
- New platforms → Add to "Messaging Platform Tokens"
- New services → Add to "External Service Tokens"

Each new token follows the pattern:

```json
"newServiceToken": {
  "type": "securestring",
  "defaultValue": "",
  "metadata": {
    "description": "OPTIONAL: Description with format info"
  }
}
```
