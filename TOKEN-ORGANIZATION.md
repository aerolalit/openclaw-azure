# Token Organization Guide

This document explains how tokens and API keys are organized in the OpenClaw Azure deployment template for better clarity and management.

## Token Groups

### 🤖 Bot Configuration
- **appName**: Your bot's unique identifier
- **confirmTokensProvided**: Required safety check

### 🤝 Messaging Platform Tokens
**At least ONE required:**
- **discordBotToken**: Discord bot token (starts with `MT` or `MQ`)
- **telegramBotToken**: Telegram bot token (format: `123456789:ABC...`)
- **slackBotToken**: Slack bot token (starts with `xoxb-`)
- **whatsappToken**: WhatsApp Business API token

### 🧠 AI/LLM API Keys  
**Anthropic required, others optional:**
- **anthropicApiKey**: 🔑 **REQUIRED** - Claude API key (starts with `sk-ant-`)
- **openaiApiKey**: OpenAI API key for GPT models (starts with `sk-`)
- **groqApiKey**: Groq API key for fast inference (starts with `gsk_`)
- **cohereApiKey**: Cohere API key for additional models

### 🌐 External Service Tokens
**All optional:**
- **elevenlabsApiKey**: Text-to-speech/voice cloning
- **braveSearchApiKey**: Enhanced web search capabilities
- **githubToken**: Repository interactions (starts with `ghp_`)
- **notionApiKey**: Notion integrations (starts with `secret_`)

### 🔗 Gateway & Federation Tokens
**Advanced features:**
- **gatewayToken**: Multi-instance federation
- **webhookSecret**: Incoming webhook authentication

### ⚙️ Infrastructure Settings
**Azure deployment config:**
- **location**: Azure region
- **containerCpu**: CPU allocation (0.5-2.0)
- **containerMemory**: Memory allocation (1Gi-4Gi)
- **logRetentionDays**: Log retention period

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

## Visual Organization Benefits

1. **Clear sections** with visual separators (═══)
2. **Emoji icons** for quick identification
3. **Required vs Optional** clearly marked
4. **Related tokens grouped together**
5. **Infrastructure settings separate** from API keys

## Deployment Order

The template validates tokens in this order:
1. Check confirmation checkbox
2. Verify at least one messaging platform token
3. Validate Anthropic API key format
4. Validate other API key formats (if provided)
5. Proceed with deployment only if all validations pass

## Security Notes

- All tokens stored in Azure Key Vault
- Access controlled via Managed Identity
- No tokens visible in logs or outputs
- Each token type has its own secret in Key Vault

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