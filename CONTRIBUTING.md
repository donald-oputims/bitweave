# Contributing to BitWeave

Thank you for your interest in contributing to BitWeave! We welcome contributions from the community to help build the future of decentralized social networking.

## 🤝 Code of Conduct

This project follows the [Contributor Covenant Code of Conduct](https://www.contributor-covenant.org/version/2/1/code_of_conduct/). By participating, you are expected to uphold this code.

## 🚀 Getting Started

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) v2.0+
- [Node.js](https://nodejs.org/) v16+
- [Git](https://git-scm.com/)
- Basic understanding of Clarity and Stacks blockchain

### Setting Up Development Environment

1. Fork the repository
2. Clone your fork:

   ```bash
   git clone https://github.com/your-username/bitweave.git
   cd bitweave
   ```

3. Install dependencies:

   ```bash
   npm install
   ```

4. Verify setup:

   ```bash
   clarinet check
   npm test
   ```

## 📋 How to Contribute

### Reporting Bugs

1. Check if the issue already exists in [GitHub Issues](https://github.com/donald-oputims/bitweave/issues)
2. If not, create a new issue with:
   - Clear description of the bug
   - Steps to reproduce
   - Expected vs actual behavior
   - Environment details (OS, Clarinet version, etc.)

### Suggesting Enhancements

1. Check existing issues and discussions
2. Create a new issue with:
   - Clear feature description
   - Use cases and benefits
   - Implementation suggestions (if any)

### Contributing Code

#### Branch Naming Convention

- `feat/feature-name` - New features
- `fix/bug-description` - Bug fixes
- `docs/update-description` - Documentation updates
- `test/test-description` - Test improvements
- `refactor/component-name` - Code refactoring

#### Development Workflow

1. Create a new branch:

   ```bash
   git checkout -b feat/your-feature-name
   ```

2. Make your changes following our coding standards

3. Write or update tests:

   ```bash
   npm test
   ```

4. Check contract validity:

   ```bash
   clarinet check
   ```

5. Commit your changes:

   ```bash
   git commit -m "feat: add new feature description"
   ```

6. Push to your fork:

   ```bash
   git push origin feat/your-feature-name
   ```

7. Create a Pull Request

## 📝 Coding Standards

### Clarity Code Style

```clarity
;; Use descriptive comments for all functions
;; Format: Brief description of what the function does
(define-public (function-name (param1 type) (param2 type))
  (let
    (
      ;; Use descriptive variable names
      (descriptive-var-name (some-operation))
    )
    ;; Clear assertion messages
    (asserts! (condition) ERR_DESCRIPTIVE_ERROR)
    
    ;; Proper error handling
    (try! (some-operation))
    
    ;; Return meaningful values
    (ok result)
  )
)
```

### Key Principles

1. **Clear Naming**: Use descriptive names for variables, functions, and constants
2. **Error Handling**: Always handle errors appropriately with descriptive error codes
3. **Documentation**: Comment complex logic and public functions
4. **Testing**: Write comprehensive tests for all new functionality
5. **Security**: Follow security best practices for blockchain development

### Error Code Convention

```clarity
;; Error codes should be sequential and descriptive
(define-constant ERR_DESCRIPTIVE_NAME (err uXXX))
```

- `u100-u199`: Authentication/Authorization errors
- `u200-u299`: Validation errors
- `u300-u399`: State errors
- `u400-u499`: Business logic errors

## 🧪 Testing Guidelines

### Writing Tests

```typescript
import { describe, expect, it } from "vitest";

describe("Feature Name", () => {
  it("should describe what the test does", () => {
    // Arrange
    const input = "test-input";
    
    // Act
    const { result } = simnet.callPublicFn(
      "bitweave",
      "function-name",
      [Cl.stringAscii(input)],
      address1
    );
    
    // Assert
    expect(result).toBeOk(Cl.uint(1));
  });
});
```

### Test Categories

1. **Unit Tests**: Test individual functions
2. **Integration Tests**: Test function interactions
3. **Edge Cases**: Test boundary conditions
4. **Error Cases**: Test all error conditions

### Running Tests

```bash
# Run all tests
npm test

# Run with coverage
npm run test:report

# Watch mode
npm run test:watch
```

## 📚 Documentation

### Documentation Standards

1. **README**: Keep the main README up-to-date
2. **Code Comments**: Comment complex logic
3. **Function Documentation**: Document all public functions
4. **API Documentation**: Document contract interfaces

### Adding Documentation

- Update relevant documentation when adding features
- Include examples for new functionality
- Update API references for contract changes

## 🔍 Pull Request Guidelines

### Before Submitting

- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Tests pass locally
- [ ] Documentation updated
- [ ] No merge conflicts

### Pull Request Description

Include:

- Brief description of changes
- Issue number (if applicable)
- Testing performed
- Breaking changes (if any)

### Review Process

1. Automated checks must pass
2. Code review by maintainers
3. Testing verification
4. Final approval and merge

## 🏷️ Release Process

### Versioning

We follow [Semantic Versioning](https://semver.org/):

- `MAJOR.MINOR.PATCH`
- Major: Breaking changes
- Minor: New features (backward compatible)
- Patch: Bug fixes

### Release Notes

- Document all changes
- Highlight breaking changes
- Include upgrade instructions

## 🎯 Priority Areas

We're currently looking for contributions in:

1. **Testing**: Expand test coverage
2. **Documentation**: Improve documentation
3. **Security**: Security audits and improvements
4. **Performance**: Gas optimization
5. **Features**: New protocol features

## 💬 Getting Help

- **Questions**: Use [GitHub Discussions](https://github.com/donald-oputims/bitweave/discussions)
- **Real-time Chat**: Join the [Stacks Discord](https://discord.gg/stacks)
- **Documentation**: Check [Stacks Documentation](https://docs.stacks.co/)

## 🙏 Recognition

Contributors will be:

- Listed in the project README
- Mentioned in release notes
- Invited to community calls

Thank you for contributing to BitWeave! 🚀
