# How to Get a Discord Bot Token

Your OpenClaw needs a Discord bot token to connect to your Discord server. Here's how to get one:

## Step 1: Go to Discord Developer Portal

Visit: https://discord.com/developers/applications

Log in with your Discord account.

## Step 2: Create a New Application

1. Click **"New Application"** (blue button in top right)
2. Give it a name like `OpenClaw - My Server`
3. Click **"Create"**

## Step 3: Create a Bot User

1. In the left sidebar, click **"Bot"**
2. Click **"Add Bot"**
3. Click **"Yes, do it!"** to confirm

## Step 4: Get Your Token

1. Under the "Token" section, click **"Reset Token"**
2. Click **"Yes, do it!"** to confirm
3. Copy the token (starts with `MT...`)
4. **⚠️ Keep this token secret!** Don't share it publicly.

## Step 5: Configure Bot Permissions

Still in the Bot section:

1. Scroll down to **"Privileged Gateway Intents"**
2. Enable these three options:
   - ✅ **Presence Intent**
   - ✅ **Server Members Intent** 
   - ✅ **Message Content Intent**
3. Click **"Save Changes"**

## Step 6: Get Invitation Link

1. In the left sidebar, click **"OAuth2"** → **"URL Generator"**
2. Under **"Scopes"**, check:
   - ✅ `bot`
   - ✅ `applications.commands`
3. Under **"Bot Permissions"**, check:
   - ✅ Send Messages
   - ✅ Read Message History
   - ✅ Use Slash Commands
   - ✅ Add Reactions
   - ✅ Attach Files
   - ✅ Embed Links
4. Copy the **"Generated URL"** at the bottom

## Step 7: Invite Bot to Your Server

1. Open the URL you copied in a new tab
2. Select the Discord server where you want OpenClaw
3. Click **"Continue"**
4. Click **"Authorize"**
5. Complete any verification prompts

## Step 8: Test the Bot

Go to your Discord server. You should see your bot listed in the member list (it will be offline until you deploy OpenClaw).

## What You Need for OpenClaw

When deploying OpenClaw, you'll need:
- **Discord Bot Token**: The token that starts with `MT...`

## ⚠️ Security Notes

- **Never share your bot token** in Discord, screenshots, or public places
- If you accidentally expose it, go back to the Discord Developer Portal and reset it
- Each bot token is unique to your application

## Troubleshooting

**Problem**: Can't see the "Add Bot" button
**Solution**: Make sure you created an Application first (Step 2)

**Problem**: Bot appears offline in Discord
**Solution**: This is normal until you deploy OpenClaw to Azure

**Problem**: Bot can't send messages
**Solution**: Check that you gave it the "Send Messages" permission in Step 6

---

**Next**: Get your [Anthropic API Key](get-anthropic-key.md)