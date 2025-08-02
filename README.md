# BitWeave 🕸️

> **Bitcoin-Secured Decentralized Social Graph Protocol**

[![Stacks](https://img.shields.io/badge/Stacks-Layer%202-purple)](https://stacks.co)
[![Clarity](https://img.shields.io/badge/Clarity-Smart%20Contract-blue)](https://clarity-lang.org)
[![License](https://img.shields.io/badge/License-ISC-green.svg)](LICENSE)
[![Tests](https://img.shields.io/badge/Tests-Vitest-yellow)](https://vitest.dev)

## Overview

BitWeave transforms social interactions into a trust-based ecosystem where every connection, endorsement, and contribution is secured by Bitcoin's immutable ledger through Stacks Layer 2. Users build verifiable reputation through stake-backed social actions, creating the first truly decentralized social credit system powered by sound money principles.

## 🌟 Key Features

### Stake-Backed Social Interactions

- **Profile Creation**: 1 STX minimum stake requirement for authentic identity
- **Content Boosting**: 0.1 STX minimum for promoting posts
- **Endorsements**: 0.5 STX stake for credible content and profile endorsements
- **Reputation Staking**: Additional STX staking to amplify reputation scores

### Decentralized Social Graph

- **Immutable Relationships**: All follows and connections stored on Bitcoin via Stacks
- **Verifiable Reputation**: Transparent, stake-weighted reputation calculation
- **Content Ownership**: Users maintain full control of their social data
- **Cross-Platform Identity**: Portable social graph across applications

### Economic Incentives

- **Merit-Based System**: Reputation earned through provable stake and community validation
- **Content Monetization**: Revenue sharing through post boosting and endorsements
- **Anti-Spam Protection**: Financial barriers prevent bot activity and spam
- **Community Validation**: Stake-weighted voting for content quality

## 🏗️ Architecture

### Core Components

```text
┌─────────────────────────────────────────────────────────────┐
│                    BitWeave Protocol                        │
├─────────────────────────────────────────────────────────────┤
│  Profile Management  │  Social Graph   │  Content System   │
│  • Identity Creation │  • Following    │  • Post Creation  │
│  • Stake Management  │  • Reputation   │  • Endorsements   │
│  • Profile Updates   │  • Metrics      │  • Boosting       │
└─────────────────────────────────────────────────────────────┘
│                      Stacks Layer 2                        │
└─────────────────────────────────────────────────────────────┘
│                     Bitcoin Network                        │
└─────────────────────────────────────────────────────────────┘
```

### Data Structures

#### User Profiles

```clarity
{
  owner: principal,
  username: string-ascii,
  bio: string-utf8,
  avatar-url: string-ascii,
  created-at: uint,
  staked-amount: uint,
  reputation-score: uint,
  follower-count: uint,
  following-count: uint,
  post-count: uint,
  total-endorsements: uint,
  is-active: bool
}
```

#### Social Connections

```clarity
{
  follower: uint,
  following: uint,
  followed-at: uint,
  is-active: bool
}
```

#### Content Posts

```clarity
{
  author: uint,
  content: string-utf8,
  created-at: uint,
  boosted-amount: uint,
  endorsement-count: uint,
  is-active: bool
}
```

## 🚀 Getting Started

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) - Stacks development environment
- [Node.js](https://nodejs.org/) v16+ - For running tests
- [Git](https://git-scm.com/) - Version control

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/donald-oputims/bitweave.git
   cd bitweave
   ```

2. **Install dependencies**

   ```bash
   npm install
   ```

3. **Verify installation**

   ```bash
   clarinet check
   ```

### Development Setup

1. **Start local development environment**

   ```bash
   clarinet console
   ```

2. **Run tests**

   ```bash
   npm test
   ```

3. **Watch mode for continuous testing**

   ```bash
   npm run test:watch
   ```

4. **Generate test coverage report**

   ```bash
   npm run test:report
   ```

## 📋 Usage Examples

### Creating a Profile

```clarity
;; Create a new profile with 1 STX stake
(contract-call? .bitweave create-profile 
  "alice" 
  "Building the future of social networks" 
  "https://avatar.example.com/alice.jpg")
```

### Following a User

```clarity
;; Follow user with profile-id 2
(contract-call? .bitweave follow-user u2)
```

### Creating and Boosting Content

```clarity
;; Create a post
(contract-call? .bitweave create-post 
  "Just launched my new project on Stacks! 🚀")

;; Boost a post with 0.5 STX
(contract-call? .bitweave boost-post u1 u500000)
```

### Endorsing Content

```clarity
;; Endorse a post with 0.5 STX stake
(contract-call? .bitweave endorse-post u1 u500000)

;; Endorse a profile with message
(contract-call? .bitweave endorse-profile 
  u2 
  u500000 
  "Excellent contributor to the ecosystem!")
```

## 🧪 Testing

### Running Tests

```bash
# Run all tests
npm test

# Run tests with coverage
npm run test:report

# Watch mode for development
npm run test:watch

# Check contract syntax
clarinet check
```

### Test Structure

```
tests/
├── bitweave.test.ts     # Main contract tests
└── helpers/             # Test utilities
```

### Writing Tests

```typescript
import { describe, expect, it } from "vitest";

describe("BitWeave Protocol", () => {
  it("should create a profile successfully", () => {
    const { result } = simnet.callPublicFn(
      "bitweave",
      "create-profile",
      [Cl.stringAscii("alice"), Cl.stringUtf8("Bio"), Cl.stringAscii("avatar.jpg")],
      address1
    );
    expect(result).toBeOk(Cl.uint(1));
  });
});
```

## 🔧 Configuration

### Clarinet Configuration

The project uses Clarinet for smart contract development. Key configuration in `Clarinet.toml`:

```toml
[project]
name = 'bitweave'
description = 'Bitcoin-Secured Decentralized Social Graph Protocol'
clarity_version = 3
epoch = 3.1

[contracts.bitweave]
path = 'contracts/bitweave.clar'
```

### Network Settings

- **Devnet**: `settings/Devnet.toml`
- **Testnet**: `settings/Testnet.toml`
- **Mainnet**: `settings/Mainnet.toml`

## 📊 Economic Model

### Stake Requirements

| Action | Minimum Stake | Purpose |
|--------|---------------|---------|
| Profile Creation | 1 STX | Identity verification |
| Post Boosting | 0.1 STX | Content promotion |
| Endorsements | 0.5 STX | Quality validation |
| Additional Staking | 0.1 STX | Reputation enhancement |

### Reputation Calculation

```clarity
reputation-score = base-stake + 
                   (followers × 1000) + 
                   (endorsements × 2000) + 
                   (posts × 500)
```

### Fee Structure

- **Protocol Fee**: 1% (100 basis points) - configurable by contract owner
- **Maximum Fee Cap**: 10% (1000 basis points)

## 🛡️ Security Features

### Stake-Based Security

- Financial barriers prevent spam and bot activity
- Economic incentives align user behavior with network health
- Stake slashing potential for malicious behavior

### Access Controls

- Profile ownership verification
- Username uniqueness enforcement
- Self-action prevention (self-follow, self-endorse)

### Error Handling

- Comprehensive error codes for all failure cases
- Input validation for all public functions
- Balance and permission checks

## 🗺️ Roadmap

### Phase 1: Core Protocol ✅

- [x] Profile management system
- [x] Social graph implementation
- [x] Content creation and management
- [x] Stake-based endorsements
- [x] Reputation scoring

### Phase 2: Enhanced Features 🚧

- [ ] Advanced reputation algorithms
- [ ] Content categorization and tagging
- [ ] Multi-signature profile management
- [ ] Delegation and proxy voting

### Phase 3: Ecosystem Integration 📋

- [ ] Cross-chain social graph bridges
- [ ] Integration with existing social platforms
- [ ] Mobile SDK development
- [ ] Governance token implementation

### Phase 4: Advanced Features 📋

- [ ] Privacy-preserving social interactions
- [ ] AI-powered content curation
- [ ] Decentralized content delivery
- [ ] Community-driven moderation

## 🤝 Contributing

We welcome contributions to BitWeave! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### Development Workflow

1. Fork the repository
2. Create a feature branch
3. Write tests for your changes
4. Implement your feature
5. Ensure all tests pass
6. Submit a pull request

### Code Standards

- Follow Clarity best practices
- Write comprehensive tests
- Document public functions
- Use meaningful variable names
- Include error handling

## 📄 License

This project is licensed under the ISC License - see the [LICENSE](LICENSE) file for details.

## 🔗 Links

- [Stacks Documentation](https://docs.stacks.co/)
- [Clarity Language Reference](https://clarity-lang.org/)
- [Clarinet Documentation](https://docs.hiro.so/clarinet/)
- [Project Repository](https://github.com/donald-oputims/bitweave)
