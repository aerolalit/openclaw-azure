# Azure Template Token Improvements

## Current vs Improved Structure

### Current Template Issues
1. **Mixed organization**: Bot tokens, API keys, and infrastructure settings all mixed together
2. **Limited token support**: Only Discord, Telegram, and Anthropic
3. **Basic validation**: Only length checks, no format validation
4. **Poor visual clarity**: No grouping or clear sections

### Improved Template Benefits

#### ✅ Visual Organization
- **Clear sections** with emoji headers and visual separators
- **Logical grouping** of related tokens
- **Required vs optional** clearly marked
- **Easy to scan** and understand

#### ✅ Comprehensive Token Support
**New tokens added:**
- **Slack bot token** for Slack integration
- **WhatsApp token** for WhatsApp Business API
- **OpenAI API key** for GPT models and image generation
- **Groq API key** for fast inference
- **Cohere API key** for additional AI models
- **ElevenLabs API key** for text-to-speech
- **Brave Search API key** for enhanced web search
- **GitHub token** for repository interactions
- **Notion API key** for Notion integrations
- **Gateway token** for multi-instance federation
- **Webhook secret** for incoming integrations

#### ✅ Enhanced Validation
- **Format validation**: Checks token prefixes (sk-ant-, xoxb-, etc.)
- **Multiple platform support**: At least one messaging platform required
- **Better error messages**: More specific validation feedback

#### ✅ Future-Proof Structure
- **Easy to extend**: Clear pattern for adding new tokens
- **Maintainable**: Grouped by function, not randomly ordered
- **Scalable**: Supports growing ecosystem of integrations

## Token Group Breakdown

### 🤖 Bot Configuration (2 parameters)
- Core setup and validation

### 🤝 Messaging Platform Tokens (4 parameters)
- Discord, Telegram, Slack, WhatsApp
- At least one required

### 🧠 AI/LLM API Keys (4 parameters)  
- Anthropic (required), OpenAI, Groq, Cohere
- Primary AI capabilities

### 🌐 External Service Tokens (4 parameters)
- ElevenLabs, Brave Search, GitHub, Notion
- Optional enhanced features

### 🔗 Gateway & Federation Tokens (2 parameters)
- Multi-instance and webhook support
- Advanced networking features

### ⚙️ Infrastructure Settings (4 parameters)
- Azure deployment configuration
- Separate from API concerns

## Migration Path

### For Existing Deployments
1. **No breaking changes**: All current parameters maintained
2. **Backward compatible**: Existing deployments continue working
3. **Optional additions**: New tokens are optional by default

### For New Deployments
1. **Better UX**: Clearer sections and descriptions
2. **More features**: Additional integrations available out-of-the-box
3. **Better validation**: Catches configuration errors early

## Validation Improvements

### Current Validation
```json
"anthropicApiKey": {
  "minLength": 20,
  "metadata": {
    "description": "Basic description"
  }
}
```

### Improved Validation
```json
"anthropicApiKey": {
  "minLength": 20,
  "metadata": {
    "description": "🔑 REQUIRED: Anthropic Claude API key from console.anthropic.com. Must start with 'sk-ant-' (e.g., sk-ant-api03-...). This is your primary AI model."
  }
}
```

Plus runtime validation:
```json
"anthropicKeyValid": "[and(variables('hasAnthropicKey'), startsWith(parameters('anthropicApiKey'), 'sk-ant-'))]"
```

## Implementation

The improved template:
1. **Maintains compatibility** with current deployments
2. **Adds new optional tokens** for extended functionality
3. **Improves validation** for better error handling
4. **Provides clear documentation** for each token type

Ready to replace the current `azuredeploy.json` with the improved version!