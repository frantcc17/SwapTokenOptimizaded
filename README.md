# SwapTokenOptimizaded
# 🌊 Surplus Capture Swap (The "Optimistic" Proxy)

> **Don't leave money on the table. Capture it.**

![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)
![Solidity](https://img.shields.io/badge/Solidity-0.8.30-blue)
![Framework](https://img.shields.io/badge/Framework-Foundry-orange)

## 📖 The Concept
In the dark forest of DeFi, users often set a high "Slippage Tolerance" (e.g., 5% or 10%) just to ensure their transaction goes through during volatile times. Usually, if the market execution is better than expected, the user silently receives the extra tokens.

**Surplus Capture Swap** changes this paradigm. It acts as an execution proxy layer on top of **Uniswap V2** that performs **Internal Arbitrage** on the user's execution parameters.

### 🧠 The Philosophy: "Monetizing Paranoia"
This protocol turns the user's inefficiency (setting a low `amountOutMin`) into a revenue stream.

| Scenario | User Request (Min) | Market Output | Result |
| :--- | :--- | :--- | :--- |
| **Traditional Swap** | 100 Tokens | 110 Tokens | User gets 110 |
| **Surplus Swap** | 100 Tokens | 110 Tokens | **Protocol takes 5**, User gets 105 |

---

## ⚙️ How It Works (The Mechanics)

The contract sits between the User and the DEX Router. It operates in 4 atomic steps:

1.  **Intercept:** The contract receives the tokens from the user.
2.  **Execute:** It performs the swap on the V2 Router using the user's parameters.
3.  **Audit:** It compares the `Actual Output` received vs. the `Minimum Output` requested.
4.  **Distribute:**
    * If `Actual > Minimum` (Positive Slippage) -> **Trigger Surplus Splitter (50/50)**.
    * If `Actual == Minimum` -> Pass through funds normally.

### 📊 Flow Logic
`User Wallet` -> `Proxy Contract` -> `Uniswap Router` -> `Proxy Checks Surplus` -> `Split Profit` -> `Treasury & User`

---

## 🛠 Tech Stack & Specs

* **Language:** Solidity `0.8.30`
* **Core Integration:** Uniswap V2 Router Interface
* **Security:** OpenZeppelin `SafeERC20` & `IERC20`
* **Revenue Model:** Hardcoded `5000 BPS` (50%) take rate on positive slippage.

---

## 🚀 Key Features

### 1. Invisible Revenue Stream
Unlike trading fees that discourage volume, this fee is **only taken when the execution is better than promised**. The user effectively never gets "less" than what they signed for.

### 2. On-Chain Analytics
The contract emits a rich `SwapTokens` event for every transaction, allowing indexers (The Graph / Goldsky) to track:
* `actualOut`: The real market performance.
* `protocolProfit`: The revenue generated per transaction.
* `userAmount`: The final settlement.

### 3. Treasury Management
Includes a designated `tesorery` address that automatically collects the captured yield, separating operational logic from fund accumulation.

---

## ⚠️ Risks & Trade-offs

| Pros | Cons |
| :--- | :--- |
| **Zero Fixed Fees:** No cost if no surplus. | **Gas Overhead:** More expensive than a direct Uniswap swap due to extra logic. |
| **Value Capture:** Monetizes volatility. | **MEV Sandwiches:** External bots might extract the value before your contract does. |
| **Trust:** Non-custodial (atomic execution). | **Rigidity:** Router address and fees are immutable (for trust). |

---

## 🧑‍💻 Getting Started (Foundry)

This project is built using **Foundry**.

### 1. Installation
```bash
git clone [https://github.com/your-username/surplus-swap](https://github.com/your-username/surplus-swap)
cd surplus-swap
forge install
