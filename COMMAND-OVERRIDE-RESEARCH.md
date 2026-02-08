# Azure Container Apps Command Override - Research & Solution

## 🚨 **Current Issue**

Container keeps showing OpenClaw help text instead of starting the gateway:
```
🦞 OpenClaw 2026.2.6-3 (unknown) — End-to-end encrypted, drama-to-drama excluded.
Usage: openclaw [options] [command]
```

This means Azure Container Apps is **completely ignoring our command overrides**.

## 🔬 **Research Findings**

After investigating Azure Container Apps documentation and blog posts:

### **Key Discovery from Azure Blog:**
> "Command override refers to what is seen in the portal... This is the same concept of overriding a containers ENTRYPOINT or CMD with a custom command"

### **Critical Requirements:**
1. ✅ **Use proper array format** in ARM templates
2. ✅ **Specify full command path** when needed  
3. ✅ **Include all arguments** in the command array
4. ✅ **Don't rely on shell wrappers** - use direct execution

## 📋 **What We Tried (Evolution)**

### ❌ **Attempt 1: Complex shell command**
```json
"command": ["/bin/sh"],
"args": ["-c", "openclaw start && openclaw channels enable..."]
```
**Result:** Permission denied (openclaw commands didn't exist)

### ❌ **Attempt 2: Docker documentation approach**  
```json
"command": ["node"],
"args": ["dist/index.js"]
```
**Result:** Azure ignored the override, still showed help

### ❌ **Attempt 3: Combined array (Azure style)**
```json
"command": ["node", "dist/index.js"]
```
**Result:** Still ignored by Azure Container Apps

### ❌ **Attempt 4: OpenClaw CLI command**
```json
"command": ["openclaw", "gateway"]
```
**Result:** "executable file not found in $PATH"

### ❌ **Attempt 5: Shell wrapper approach**
```json
"command": ["/bin/sh"],
"args": ["-c", "node dist/index.js gateway --port 18789 || node dist/index.js"]
```
**Result:** Still showed help text (override ignored)

### ✅ **Attempt 6: CURRENT - Direct Node.js with full args**
```json
"command": ["node", "dist/index.js", "gateway", "--port", "18789"]
```
**Strategy:** 
- Use Node.js directly (exists in container)
- Include all gateway startup arguments
- No shell wrapper complexity
- Multiple environment variables for OpenClaw config

## 🎯 **Current Solution Details**

### **Container Command:**
```json
"command": ["node", "dist/index.js", "gateway", "--port", "18789"]
```

### **Environment Variables Added:**
```json
"OPENCLAW_START_GATEWAY": "true"
"OPENCLAW_GATEWAY_PORT": "18789"  
"NODE_ENV": "production"
"OPENCLAW_AUTO_START": "gateway"
```

### **Why This Should Work:**

1. ✅ **Direct Node.js execution** (no shell complexity)
2. ✅ **Explicit gateway command** with port specification
3. ✅ **Multiple env vars** to guide OpenClaw behavior  
4. ✅ **Follows Azure Container Apps best practices**

## 🚀 **Expected Results**

After redeployment, container logs should show:
```
Gateway starting on port 18789...
OpenClaw gateway ready!
```

Instead of:
```
🦞 OpenClaw 2026.2.6-3 (unknown)...
Usage: openclaw [options] [command]
```

## 📚 **References**

- [Azure Container Apps Command Override](https://azureossd.github.io/2024/01/17/Container-Apps-Using-the-command-override-option/)
- [Azure Container Apps ARM Template Spec](https://learn.microsoft.com/en-us/azure/container-apps/azure-resource-manager-api-spec)
- [OpenClaw Docker Documentation](https://docs.openclaw.ai/install/docker)

## 🎉 **Success Criteria**

✅ Container starts without "help text" output  
✅ Gateway binds to port 18789  
✅ OpenClaw web interface accessible  
✅ No "command not found" errors  
✅ No container restart loops  

This should be the **final working solution**! 🤞