# Contributing to OpenClaw Azure

Thanks for your interest in improving OpenClaw Azure! This project aims to make AI assistants accessible to everyone through simple Azure deployment.

## 🎯 Goals

- **Beginner-friendly**: Non-technical users should be able to deploy easily
- **Cost-effective**: Keep deployment costs reasonable (~$48-64/month)
- **Reliable**: Deployments should work consistently across Azure regions
- **Secure**: Follow Azure security best practices

## 🐛 Reporting Issues

Before opening an issue:

1. Check the [troubleshooting guide](docs/troubleshooting.md)
2. Search existing issues to avoid duplicates
3. Use our [issue template](.github/ISSUE_TEMPLATE.md)

### Good Issues Include:

- Clear description of the problem
- Environment details (Azure region, deployment method)
- Steps to reproduce
- Error messages (with sensitive info removed)
- What you've already tried

## 💡 Suggesting Improvements

We welcome suggestions for:

- Better documentation
- Cost optimization
- Security improvements
- Deployment simplification
- Support for additional Azure regions

## 🛠️ Contributing Code

### Prerequisites

- Azure CLI installed and configured
- Basic knowledge of ARM templates
- Test access to an Azure subscription

### Areas Where We Need Help

- **Documentation**: Screenshots, step-by-step guides
- **ARM Templates**: Optimization, new features
- **Cost Analysis**: Finding cheaper alternatives
- **Regional Support**: Testing in different Azure regions
- **Error Handling**: Better error messages and recovery

### Pull Request Process

1. **Fork** the repository
2. **Create a branch** for your changes: `git checkout -b feature/your-feature-name`
3. **Make your changes** and test thoroughly
4. **Update documentation** if needed
5. **Test deployment** in a clean Azure environment
6. **Submit a pull request** with:
   - Clear description of changes
   - Why the change is needed
   - How you tested it
   - Screenshots for UI changes

### Testing Your Changes

Before submitting a PR:

1. **Test the ARM template** in a fresh resource group
2. **Verify the deployment completes** successfully
3. **Test the OpenClaw functionality** (Discord bot responds)
4. **Check cost implications** (use Azure pricing calculator)
5. **Test cleanup** (delete resource group works cleanly)

## 📝 Documentation Guidelines

- **Keep it simple**: Target non-technical users
- **Use screenshots**: Show what users should see
- **Step-by-step**: Number each step clearly
- **Confirm success**: Tell users what success looks like
- **Link related docs**: Help users find what they need

### Screenshot Guidelines

- Use consistent browser/UI settings
- Highlight important buttons/fields
- Keep sensitive information out of screenshots
- Save as PNG format
- Name descriptively (e.g., `azure-portal-create-button.png`)

## 🔒 Security Guidelines

- **Never commit secrets** (tokens, API keys, passwords)
- **Never expose secrets** in logs, outputs, or public files
- **Follow least privilege** for managed identities
- **Keep dependencies updated**
- **Review ARM templates** for security issues

## 📋 Code Style

### ARM Templates

- Use descriptive variable names
- Include metadata descriptions for all parameters
- Add comments for complex logic
- Follow Azure naming conventions
- Use latest API versions

### Documentation

- Use clear, friendly language
- Avoid technical jargon
- Include examples
- Test instructions on a real beginner

## 🚀 Release Process

1. Changes are reviewed and merged to `main`
2. Update version in deployment templates
3. Test deployment from the main branch
4. Update documentation if needed
5. Create release notes

## 🎉 Recognition

Contributors will be recognized in:

- README.md contributors section
- Release notes
- GitHub contributor graphs

## 🤝 Code of Conduct

- Be welcoming and inclusive
- Help beginners without condescension
- Focus on what's best for the project
- Show empathy for other contributors
- Respect different viewpoints and experiences

## 📧 Questions?

- **General questions**: Open a GitHub discussion
- **Security issues**: Email the maintainers directly
- **Documentation issues**: Open a GitHub issue

---

Thank you for contributing to OpenClaw Azure! 🙏
