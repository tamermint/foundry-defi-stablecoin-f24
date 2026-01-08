# 🪙 DeFi Stablecoin (Foundry)

🔐 A collateral-backed, USD-pegged stablecoin prototype focused on **correctness**, **explicit invariants**, and **property-based testing** using **Foundry**.

> ⚠️ Educational/prototyping project — **not production-ready** and **not audited**.

---

## 🧭 Overview

This repo explores a minimal overcollateralized stablecoin system with:

- 💵 **USD peg target (conceptual):** stablecoin value tracks USD using **oracle-priced collateral**
- 🧱 **Exogenous collateral:** `wETH`, `wBTC`
- 🧷 **Overcollateralization:** minting requires sufficient collateral value
- 🧠 **Protocol rule layer (“Engine”):** enforces deposits, mint/burn, and redemption constraints
- 📡 **Oracles (e.g., Chainlink feeds):** used for collateral valuation

---

## 🎯 Design Goals

- ✅ **Safety-first mechanics** — prevent undercollateralized minting and unsafe redemptions
- ✅ **Explicit invariants** — define “must-always-hold” properties and test them continuously
- ✅ **Testing as a product** — unit tests + fuzzing + invariant/property-based tests (Foundry)
- ✅ **Minimal attack surface** — small, composable modules + strict collateral allowlist

---

## 🧩 Core Components (High-level)

- 🪙 **Stablecoin (ERC20):** token that is minted/burned under protocol rules
- 🧠 **Engine:** validates collateralization, controls minting/redemption flows
- 📡 **Oracle adapters:** price reads and normalization for `wETH` / `wBTC` valuation

---

## 🧱 System Assumptions (Trust Model)

- 📡 **Oracle trust:** pricing correctness depends on oracle integrity and availability
- 🪙 **Collateral token correctness:** assumes standard ERC20 behavior for `wETH` and `wBTC`
- 🧯 **Prototype scope:** omits many production safeguards (see Security Notes)

---

## ✅ Key Invariants (Examples)

The system is designed so that:

- 🚫 **No free minting:** stablecoins cannot be minted without sufficient collateral
- 🧮 **Collateralization constraint:** the engine maintains health rules around collateral vs debt
- 🔒 **Allowlisted collateral only:** deposits/redemptions work only for supported tokens (`wETH`, `wBTC`)

> 🧪 See tests for the exact invariant definitions and fuzz coverage strategy.

---

## 🗂️ Project Layout (Typical)

- `src/` — protocol contracts (stablecoin + engine)
- `test/` — unit tests + fuzz/invariant tests
- `script/` — deployment/interaction scripts
- `.github/workflows/` — CI checks (if enabled)

---

## 🧰 Run Locally

### ✅ Prerequisites

- Foundry installed (`forge`, `cast`)

### 🏗️ Build

```bash
forge build
```

### Test

```bash
forge test -vvvv
```

---

## 🛠️ Notable Implementation Notes

🧩 ERC20Mock constructor changes (OpenZeppelin versions)

OpenZeppelin mocks and constructors differ across versions. This repo uses a simplified mock token constructor aligned with the installed OZ version (instead of relying on older multi-arg constructors).
This keeps the project compatible with current dependencies and avoids brittle test scaffolding.

🎛️ Invariant handler setup (approvals + actor realism)

- Invariant tests are driven via a handler that models realistic user interactions:

- 🪙 Mints mock collateral to the actor/handler as needed

- ✅ Approves the engine before deposits (so fuzzed actions reflect valid flows)

- 🔒 Restricts collateral selection to only allowlisted tokens (wETH, wBTC)

This prevents fuzz inputs from “testing nonsense” (invalid collateral types) and concentrates coverage on meaningful protocol states.

---

🛡️ Security Notes (Prototype)

- ⚠️ This project is not audited and is not intended for mainnet deployment.

- If productionizing, priority hardening areas include:

  - 📡 Oracle manipulation defenses: staleness checks, deviation bounds, fallback behavior

  - 🧮 Decimals/precision rigor: normalization, rounding strategy, overflow/underflow safety

  - 🔥 Liquidation design: incentives, edge cases, MEV considerations, and adversarial scenarios

  - 🧰 Operational controls: pausing/emergency controls, roles, timelocks, upgrade strategy

  - ✅ Verification: deeper invariant suites, fork tests, and external review/audit

---

🧭 Roadmap (If Productionizing)

- 📡 Add explicit oracle safety module (staleness + decimals normalization + guardrails)

- 🧪 Expand invariants (system accounting, supply/debt bounds, redeem safety)

- 🧯 Introduce liquidation flows + adversarial test scenarios

- 🌐 Add multi-network deployment configs + fork-based integration testing

- 🧾 Write a short protocol spec: invariants, trust model, failure modes, upgrade posture
