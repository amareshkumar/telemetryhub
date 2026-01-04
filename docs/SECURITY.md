# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 6.2.x   | :white_check_mark: |
| < 6.0   | :x:                |

## Reporting a Vulnerability

We take security vulnerabilities seriously. If you discover a security issue, please:

1. **DO NOT** open a public GitHub issue
2. Use GitHub's [Private Vulnerability Reporting](https://github.com/amareshkumar/telemetryhub/security/advisories/new)
3. Or email: amaresh.kumar@live.in

### What to Include

- Description of the vulnerability
- Steps to reproduce the issue
- Potential impact assessment
- Suggested fix (if available)
- Your contact information for follow-up

### Response Timeline

- **Initial Response:** Within 48 hours
- **Status Update:** Within 7 days
- **Fix Timeline:** 
  - Critical: 7 days
  - High: 14 days
  - Medium: 30 days
  - Low: 60 days

## Security Best Practices

- We use AddressSanitizer (ASAN), ThreadSanitizer (TSAN), and UndefinedBehaviorSanitizer (UBSAN)
- All PRs require code review
- Dependencies are monitored via Dependabot
- Continuous Integration runs security checks

## Disclosure Policy

- We follow coordinated disclosure practices
- Public disclosure only after fix is released
- Security researchers will be credited (unless they prefer anonymity)

Thank you for helping keep TelemetryHub secure!
