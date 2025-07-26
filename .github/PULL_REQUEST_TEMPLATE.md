# Pull Request

## 📝 Description
Brief description of changes made in this PR.

## 🔗 Related Issues
Closes #(issue number)
Related to #(issue number)

## 🎯 Type of Change
Please check the relevant option:

- [ ] 🐛 Bug fix (non-breaking change which fixes an issue)
- [ ] ✨ New feature (non-breaking change which adds functionality)
- [ ] 💥 Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] 📚 Documentation update
- [ ] 🎨 Code style/formatting changes
- [ ] ♻️ Code refactoring (no functional changes)
- [ ] ⚡ Performance improvements
- [ ] 🧪 Adding or updating tests
- [ ] 🔧 Build/config changes

## 🧪 Testing
Please describe how you tested your changes:

### Manual Testing
- [ ] Tested on iOS device/simulator
- [ ] Tested on Android device/emulator
- [ ] Tested on web browser
- [ ] Tested with different screen sizes
- [ ] Tested camera functionality (if applicable)
- [ ] Tested location services (if applicable)
- [ ] Tested offline functionality (if applicable)

### Automated Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] E2E tests pass (if applicable)
- [ ] No new linting errors
- [ ] No new TypeScript errors

## 📸 Screenshots/Videos
If applicable, add screenshots or videos demonstrating the changes:

### Before
<!-- Add screenshots of the current state -->

### After
<!-- Add screenshots of the new state -->

## 🔍 Code Review Checklist

### General
- [ ] Code follows the project's coding standards
- [ ] Self-review of the code completed
- [ ] Code is well-commented, particularly in hard-to-understand areas
- [ ] No debugging code or console logs left in the code
- [ ] No hardcoded values that should be configurable

### React Native Specific
- [ ] Components follow functional component patterns
- [ ] Proper use of hooks (useEffect, useState, etc.)
- [ ] No memory leaks (proper cleanup in useEffect)
- [ ] Platform-specific code properly implemented
- [ ] Accessibility features implemented where needed

### Performance
- [ ] No unnecessary re-renders
- [ ] Optimal use of React.memo/useMemo/useCallback where needed
- [ ] Image optimization implemented
- [ ] No blocking operations on the main thread

### Security
- [ ] No sensitive data exposed in logs or error messages
- [ ] API keys and secrets properly configured
- [ ] Input validation implemented where needed
- [ ] Permissions properly requested and handled

## 📚 Documentation
- [ ] Documentation updated (if needed)
- [ ] README.md updated (if needed)
- [ ] API documentation updated (if applicable)
- [ ] Comments added for complex logic

## 🚀 Deployment Considerations
- [ ] Environment variables updated (if needed)
- [ ] Database migrations included (if applicable)
- [ ] Backward compatibility maintained
- [ ] Feature flags implemented (if needed)

## 🔄 Migration Guide
If this is a breaking change, please provide migration instructions:

## ⚠️ Known Issues
List any known issues or limitations with this PR:

## 📋 Additional Notes
Any additional information reviewers should know:

## ✅ Final Checklist
- [ ] PR title follows convention: `type(scope): description`
- [ ] All conversations resolved
- [ ] Approved by at least one maintainer
- [ ] CI/CD checks pass
- [ ] Ready for merge

---

**Note for Reviewers:**
Please ensure all checklist items are completed before approving this PR. 