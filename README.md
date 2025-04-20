# 🪙 MyToken – Custom ERC20 Implementation ![Coverage](https://img.shields.io/badge/coverage-100%25-brightgreen)  


This project is a custom-built, security-focused implementation of an ERC20 token, created from scratch without using any external libraries like OpenZeppelin. It's fully tested and achieves **100% test coverage** using Foundry's `forge coverage`.

---

## 🚀 Key Features

- ✅ Built fully from scratch (no external dependencies)
- 🔐 Secure error handling with custom errors
- 🧪 100% test coverage with Foundry
- 👨‍💻 Owner-only `mint` functionality
- 🔥 Public `burn` functionality
- 📥 `approve`, `transferFrom`, `increaseAllowance`, `decreaseAllowance` support
- 🚫 Custom reverts for cleaner gas-efficient error messages
- 🧱 `MAX_SUPPLY` constraint enforced

---

## 🔍 Contract Overview

| Function              | Description                                                              |
|-----------------------|--------------------------------------------------------------------------|
| `constructor`         | Initializes token with name, symbol, decimals, and initial supply        |
| `mint()`              | Owner-only function to mint tokens without exceeding `MAX_SUPPLY`        |
| `burn()`              | Burns caller's tokens                                                    |
| `transfer()`          | Transfers tokens to another address                                      |
| `approve()`           | Approves a spender to spend on caller's behalf                           |
| `transferFrom()`      | Allows spending tokens via allowance                                     |
| `increaseAllowance()` | Safely increases allowance for a spender                                 |
| `decreaseAllowance()` | Safely decreases allowance for a spender                                 |

---

## 🛡️ Custom Errors

Custom errors are used instead of revert strings to save gas and improve readability:

- `MyToken__NotOwner()`
- `MyToken__MaxSupplyExceeds()`
- `MyToken__NotEnoughTokens()`
- `MyToken__InvalidAddress()`
- `MyToken__AllowanceExceeds()`
- `MyToken__NotEnoughAllowance()`

---

## 🔧 Tech Stack

- **Solidity**: `^0.8.24`
- **Framework**: [Foundry](https://book.getfoundry.sh/)
- **Test Coverage**: 100% via `forge coverage`

---

## ✅ Getting Started

### 🔗 Clone Repo

```bash
git clone https://github.com/Eunum56/foundry-ERC20
cd foundry-ERC20
```

### 🧪 Install & Run Tests

```bash
forge install
forge build
forge test
```

---

## Contributing

Feel free to fork this repository and submit pull requests. If you have suggestions or encounter any bugs, please open an issue in the GitHub repository.

---

<p align="center">
  <i>Built with ❤️, tested with 🧪, and deployed with 💪</i>
</p>
