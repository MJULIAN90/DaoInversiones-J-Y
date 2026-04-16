# 🏛 Protocol Frontend --- Governance, Vaults & Treasury System

## 🌐 Overview

This project is a **modular frontend architecture** designed for a DeFi
protocol that integrates:

-   Governance (DAO proposals & voting)
-   Vault infrastructure (ERC4626-like)
-   Treasury management
-   Guardian-based execution layer
-   Risk monitoring and operational controls

The system is designed to be: - **Web3-agnostic at UI level** -
**Hook-driven for data and logic** - **Ready for wagmi / viem
integration** - **Scalable with The Graph / indexing layers**

------------------------------------------------------------------------

## 🧠 Architecture Principles

### 1. Separation of Concerns

  Layer        Responsibility
  ------------ -------------------------------
  UI (Pages)   Rendering only
  Hooks        Data + logic
  Contracts    External integration (future)

> UI never interacts directly with Web3.

------------------------------------------------------------------------

### 2. Capability-Based Access Control

Instead of role checks:

``` ts
// ❌ Avoid
if (role === "admin")

// ✅ Use
if (capabilities.canCreateProposal)
```

------------------------------------------------------------------------

### 3. Hook-Centric Design

Each view is powered by a hook.

------------------------------------------------------------------------

## 📁 Project Structure

src/ ├── app/ ├── pages/ ├── hooks/ ├── components/ └── styles/

------------------------------------------------------------------------

## 🧩 Core Modules

### Governance

-   Proposal creation
-   Voting
-   Execution

### Vaults

-   Deposit / Withdraw
-   Strategy execution

### Treasury

-   Asset management
-   Controlled withdrawals

### Guardians

-   Vault deployment
-   Execution control

### Risk

-   Pause system
-   Asset validation

### Admin

-   Diagnostics
-   Contract registry

------------------------------------------------------------------------

## 🔗 Routing Map

/dashboard /governance /governance/create /governance/:proposalId
/vaults /vaults/:vaultAddress /vaults/positions /vaults/guardian-tools
/treasury /treasury/operations /operations /risk /admin

------------------------------------------------------------------------

## 🎨 UI Design

-   TailwindCSS
-   Enterprise light theme

------------------------------------------------------------------------

## 🔌 Integration Plan

-   wagmi
-   viem
-   RainbowKit
-   The Graph

------------------------------------------------------------------------

## 🇪🇸 Versión en Español

Frontend modular para protocolo DeFi con gobernanza, vaults, tesorería y
capa de riesgo.

-   Arquitectura desacoplada
-   Basado en hooks
-   Escalable y listo para producción
