# Contributing to CA Certificate Import Action

Thank you for your interest in contributing! This document provides guidelines for contributing to this project.

## How to Contribute

### Reporting Bugs

Before creating bug reports, please check existing issues to avoid duplicates. When creating a bug report, include:

- **Clear title and description**
- **Steps to reproduce** the behavior
- **Expected vs actual behavior**
- **Environment details** (OS, runner version, etc.)
- **Relevant logs** (with sensitive information redacted)

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, include:

- **Clear title and description**
- **Use case** explaining why this enhancement would be useful
- **Proposed implementation** if you have ideas
- **Alternative solutions** you've considered

### Pull Requests

1. **Fork the repository** and create your branch from `main`
2. **Make your changes** following the code style guidelines
3. **Test your changes** thoroughly
4. **Update documentation** as needed
5. **Write clear commit messages**
6. **Submit a pull request**

## Development Guidelines

### Code Style

- Use clear, descriptive variable names
- Add comments for complex logic
- Follow shell scripting best practices
- Use consistent indentation (2 spaces for YAML, 4 spaces for bash)
- Include error handling for edge cases

### Testing

Before submitting a PR, ensure:

- All existing tests pass
- New functionality includes tests
- Manual testing in a workflow environment
- Test with all three input methods (file, URL, inline)

### Running Tests Locally

You can test the action locally using [act](https://github.com/nektos/act). See the [MAINTAINERS.md](MAINTAINERS.md#local-testing) guide for detailed testing instructions.

```bash
# Quick test with the provided script
./act-build.sh

# Or run the CI workflow directly
act -W .github/workflows/ci-cd.yml
```

### Documentation

- Keep README.md up to date
- Update EXAMPLES.md for new features
- Add entries to CHANGELOG.md
- Include inline comments for complex logic

## Code of Conduct

### Our Standards

- Be respectful and inclusive
- Accept constructive criticism gracefully
- Focus on what's best for the community
- Show empathy towards others

### Unacceptable Behavior

- Harassment or discriminatory comments
- Personal attacks or trolling
- Publishing others' private information
- Other conduct inappropriate in a professional setting

## Questions?

Feel free to open an issue for questions or clarifications.

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

