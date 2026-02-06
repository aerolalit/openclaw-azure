# How to Get an Anthropic API Key

OpenClaw uses Claude (by Anthropic) as its AI brain. Here's how to get your API key:

## Step 1: Create an Anthropic Account

Visit: https://console.anthropic.com/

1. Click **"Sign Up"** if you don't have an account
2. Or click **"Sign In"** if you already have one
3. Complete the signup process with your email

## Step 2: Add Credit to Your Account

⚠️ **Important**: You need to add credit before you can use the API.

1. Go to **"Settings"** (gear icon in top right)
2. Click **"Billing"** in the left sidebar
3. Click **"Add Credits"**
4. Add at least $5-10 to start (this will last a while!)
5. Complete the payment

## Step 3: Create an API Key

1. In the left sidebar, click **"API Keys"**
2. Click **"Create Key"** (or **"+ Create Key"**)
3. Give it a name like `OpenClaw Azure`
4. Click **"Create Key"**
5. **Copy the key immediately!** (starts with `sk-ant-`)
6. **⚠️ Keep this key secret!** You won't be able to see it again.

## Step 4: Test Your Key (Optional)

You can test your key works by running this command (if you have `curl`):

```bash
curl https://api.anthropic.com/v1/messages \
  -H "Content-Type: application/json" \
  -H "x-api-key: YOUR_KEY_HERE" \
  -d '{
    "model": "claude-3-haiku-20240307",
    "max_tokens": 10,
    "messages": [{"role": "user", "content": "Hello!"}]
  }'
```

If it works, you'll get a response from Claude!

## What You Need for OpenClaw

When deploying OpenClaw, you'll need:

- **Anthropic API Key**: The key that starts with `sk-ant-`

## 💰 Cost Information

Claude usage is charged separately from your Azure costs:

- **Claude 3 Haiku**: ~$0.25 per million input tokens, ~$1.25 per million output tokens
- **For typical usage**: Expect $5-15/month in Claude costs
- **Total monthly cost**: ~$27-45 (Azure ~$22-30 + Claude ~$5-15)

You can monitor your usage in the Anthropic Console under "Usage".

## ⚠️ Security Notes

- **Never share your API key** in screenshots, logs, or public places
- If you accidentally expose it, go back to the Anthropic Console and create a new one
- Set up billing alerts in the Anthropic Console to avoid surprise costs

## Managing Costs

To keep Claude costs low:

1. **Set spending limits** in the Anthropic Console:
   - Go to Settings → Billing → Spending Limits
   - Set a monthly limit (e.g., $25)

2. **Monitor usage regularly**:
   - Check Settings → Usage for daily/monthly statistics

3. **Use Claude efficiently**:
   - OpenClaw is optimized to use Claude efficiently
   - Avoid very long conversations if cost is a concern

## Troubleshooting

**Problem**: "Invalid API key" error
**Solution**: Double-check you copied the entire key (starts with `sk-ant-`)

**Problem**: "Insufficient credits" error
**Solution**: Add more credit to your Anthropic account

**Problem**: API key not working immediately
**Solution**: Wait a few minutes; it can take time to activate

## Free Tier

Anthropic sometimes offers free credits for new accounts. Check your console for any promotional credits!

---

**Next**: Ready to [deploy OpenClaw](getting-started.md#step-1-open-azure-portal)!
