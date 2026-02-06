# How to Get a Telegram Bot Token

Your OpenClaw connects to Telegram to work as your AI assistant. Here's how to create a Telegram bot and get its token:

## Step 1: Start a Chat with BotFather

Telegram uses a special bot called "BotFather" to create and manage other bots.

1. Open Telegram (on your phone, desktop, or web)
2. Search for **@BotFather**
3. Start a chat with BotFather
4. Type `/start` to begin

## Step 2: Create a New Bot

1. Type `/newbot` and send it
2. BotFather will ask for a **name** for your bot
   - This can be anything you want (e.g., "My AI Assistant")
   - This is just a display name, not unique

3. BotFather will ask for a **username** for your bot
   - This must be unique across all of Telegram
   - Must end with "bot" (e.g., `MyAssistantBot` or `JohnAIBot`)
   - Try different names if your first choice is taken

## Step 3: Get Your Bot Token

Once you create the bot successfully, BotFather will send you a message containing:

```
Done! Congratulations on your new bot. You will find it at t.me/YourBotName.
You can now add a description, about section and profile picture for your bot.

Use this token to access the HTTP API:
123456789:ABCdef1234567890abcdef1234567890ABC

Keep your token secure and store it safely, it can be used by anyone to control your bot.
```

**Copy the token** - it's the long string of numbers and letters after "Use this token to access the HTTP API:"

## Step 4: Configure Privacy Settings (Important!)

By default, Telegram bots can only see messages that mention them directly. To make your OpenClaw work properly:

1. Type `/mybots` to BotFather
2. Select your bot from the list
3. Choose **"Bot Settings"**
4. Choose **"Group Privacy"**
5. Choose **"Disable"** (this allows your bot to see all messages in groups)

## Step 5: Test Your Bot

1. Search for your bot by username in Telegram (e.g., `@YourBotName`)
2. Click "START" or type `/start`
3. The bot won't respond yet (that's normal - it needs to be deployed first)

## Step 6: Add to Groups (Optional)

If you want your OpenClaw in a Telegram group:

1. Create a group or open an existing one
2. Add members -> Search for your bot username
3. Add your bot to the group
4. Make your bot an admin (recommended for full functionality)

## Token Format

Your Telegram bot token should look like this:

- `123456789:ABCdef1234567890abcdef1234567890ABC`
- It's always: **numbers** : **letters and numbers**
- Should be about 45-50 characters total

## Security Note

**Keep your token secret!** Anyone with this token can control your bot. Never share it publicly.

## Step 7: Get Your Telegram User ID (Optional)

If you provide your Telegram user ID during deployment, the bot will work immediately without manual pairing.

1. Open Telegram and search for **@userinfobot**
2. Start a chat and send any message
3. The bot will reply with your user info, including your **numeric ID** (e.g., `455368171`)
4. Copy this number and use it in the **"telegramUserId"** field when deploying

## What's Next?

1. **Copy your bot token** and save it somewhere safe
2. Use it in the **"Telegram Bot Token"** field when deploying OpenClaw
3. Optionally add your **Telegram User ID** (see step above)
4. You'll also need an [Anthropic API key](get-anthropic-key.md)

---

**Need help?** Check our [troubleshooting guide](../VM-DEPLOYMENT.md#troubleshooting) or [open a GitHub issue](https://github.com/aerolalit/openclaw-azure/issues).
