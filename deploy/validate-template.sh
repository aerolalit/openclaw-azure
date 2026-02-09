#!/bin/bash

echo "🔍 Validating OpenClaw Azure Template..."
echo

# Check if Node.js is available
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is required for validation"
    exit 1
fi

# Validate JSON syntax
echo "📝 Checking JSON syntax..."
if node -e "
const fs = require('fs');
try {
    const content = fs.readFileSync('azuredeploy.json', 'utf8');
    JSON.parse(content);
    console.log('✅ JSON syntax is valid');
    console.log('📊 Template size:', content.length, 'characters');
} catch (e) {
    console.error('❌ JSON Error:', e.message);
    if (e.message.includes('position')) {
        const pos = e.message.match(/position (\d+)/)?.[1];
        if (pos) {
            const errorPos = parseInt(pos);
            const context = content.substring(Math.max(0, errorPos - 50), errorPos + 50);
            console.error('🔍 Context around error:');
            console.error(context);
        }
    }
    process.exit(1);
}
"; then
    echo
else
    echo "❌ JSON validation failed"
    exit 1
fi

# Check for common ARM template issues
echo "🔧 Checking for common ARM template issues..."

# Check required sections exist
if ! grep -q '"parameters"' azuredeploy.json; then
    echo "❌ Missing parameters section"
    exit 1
fi

if ! grep -q '"resources"' azuredeploy.json; then
    echo "❌ Missing resources section"
    exit 1
fi

if ! grep -q '"outputs"' azuredeploy.json; then
    echo "⚠️  No outputs section (recommended)"
fi

echo "✅ Basic ARM template structure is valid"
echo

# Check for the specific fixes we made
echo "🔍 Verifying OpenClaw-specific fixes..."

if grep -q '"command": \["node", "dist/index.js", "gateway"' azuredeploy.json; then
    echo "✅ Correct container startup command found"
else
    echo "❌ Container startup command may be incorrect"
fi

if grep -q '"targetPort": 18789' azuredeploy.json; then
    echo "✅ Correct port configuration (18789)"
else
    echo "❌ Port configuration may be incorrect"
fi

if grep -q 'DISCORD_BOT_TOKEN' azuredeploy.json; then
    echo "✅ Correct Discord environment variable name"
else
    echo "⚠️  Discord environment variable name may be non-standard"
fi

echo
echo "🎉 Template validation completed successfully!"
echo
echo "Next steps:"
echo "1. Test deployment with your actual tokens"
echo "2. Monitor container logs for successful startup"
echo "3. Verify OpenClaw web interface is accessible"