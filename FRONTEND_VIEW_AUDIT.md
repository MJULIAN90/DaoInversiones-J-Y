# Frontend View Audit

Este documento resume, vista por vista, qué parte del frontend ya consume datos reales de contratos, qué sigue mockeado, y qué depende de indexación/eventos o de cambios en Solidity.

## Criterios

- `Real`: la vista ya lee o escribe directamente contra contratos desplegados.
- `Parcial`: mezcla de reads/writes reales con placeholders, fallbacks o limitaciones del contrato.
- `Mockeado`: la mayor parte de la vista sigue usando datos estáticos o armados localmente.
- `Limitación de contrato`: el frontend no puede completar mejor esa parte solo con `view`, porque el Solidity actual no expone lo necesario.

## Resumen Ejecutivo

### Vistas más maduras

- `bonding`
- `vaults`
- `vault detail` como lectura
- `guardians`
- `guardian tools`
- `treasury operations`
- `operations`
- `risk`
- `treasury` parcial-real
- `admin` parcial-real

### Vistas con más trabajo pendiente

- `governance/:id`
- `governance/create`
- `vaults/positions`
- `dashboard.activity`

---

## 1. Dashboard

### Ruta

- `/dashboard`

### Hook principal

- [frontend/src/hooks/useDashboardModel.ts](./frontend/src/hooks/useDashboardModel.ts)

### Estado

- `Parcial-real`

### Real desde contratos

- `VaultRegistry.totalVaults()`
- `Treasury.nativeBalance()`
- `Treasury.erc20Balance(token)`
- `DaoGovernor.proposalThreshold()`
- `GenesisBonding.isFinalized()`
- `ProtocolCore.isVaultCreationPaused()`
- `ProtocolCore.isVaultDepositsPaused()`
- `RiskManager.executionPaused()`
- `GuardianAdministrator.totalActiveGuardians()`

### Mockeado / pendiente

- `activity` está completamente estática.

### Qué falta para cerrarla

- Indexación de eventos como:
  - creación de vaults
  - compras de bonding
  - guardian applications
  - treasury updates

### Observación

- La cabecera y métricas principales sí tienen base on-chain.
- El “Recent Activity” no debería venderse como real todavía.
- La vista ya no depende de mocks para métricas, solo para actividad histórica.

---

## 2. Bonding

### Ruta

- `/bonding`

### Hook principal

- [frontend/src/hooks/useBondingModel.ts](./frontend/src/hooks/useBondingModel.ts)

### Estado

- `Parcial-real`

### Real desde contratos

- `GenesisBonding.isFinalized()`
- `GenesisBonding.rate()`
- `GenesisBonding.totalGovernanceTokenPurchased()`
- `ProtocolCore.getSupportedGenesisTokens()`
- `GovernanceToken.balanceOf(user)`
- `ERC20.approve(...)`
- `GenesisBonding.buy(token, amount)`

### Mockeado / pendiente

- `position.totalPurchases`

### Qué falta para cerrarla

- Leer eventos `Purchased(...)` por usuario o indexarlos.

### Observación

- El flujo de compra sí está conectado.
- El pendiente aquí es más analítico/histórico que funcional.
- `totalPurchases` sigue siendo un derivado pendiente de eventos o indexación.

---

## 3. Governance List

### Ruta

- `/governance`

### Hook principal

- [frontend/src/hooks/useGovernanceModel.ts](./frontend/src/hooks/useGovernanceModel.ts)

### Estado

- `Parcial`

### Real desde contratos

- `DaoGovernor.proposalCount()`
- `DaoGovernor.proposalDetailsAt(index)`
- `DaoGovernor.state(proposalId)`
- `DaoGovernor.proposalVotes(proposalId)`
- `DaoGovernor.proposalDeadline(proposalId)`
- `GovernanceToken.getVotes(user)`
- `DaoGovernor.proposalThreshold()`
- `DaoGovernor.votingDelay()`
- `DaoGovernor.votingPeriod()`

### Mockeado / pendiente

- El `title` de propuesta no existe realmente on-chain en esta ruta.
- La participación es un placeholder.
- `deadline` se muestra en bloques, no en timestamp real.

### Limitación de contrato

- `proposalDetailsAt(index)` devuelve:
  - `proposalId`
  - `targets`
  - `values`
  - `calldatas`
  - `descriptionHash`
- No devuelve un `title` legible.

### Qué falta para cerrarla

- Metadata indexada por `proposalId`
- o una convención de almacenamiento externo para título/descripcion

### Observación

- La lista ya no está mockeada, pero sí está limitada por el diseño actual del governor.

---

## 4. Governance Detail

### Ruta

- `/governance/:proposalId`

### Hook principal

- [frontend/src/hooks/useProposalDetailModel.ts](./frontend/src/hooks/useProposalDetailModel.ts)

### Estado

- `Parcial`

### Real desde contratos

- Hoy casi nada.

### Mockeado / pendiente

- `title`
- `description`
- `status`
- `proposer`
- `executionEta`
- `votes`
- `timeline`
- `actions`

### Qué debería usar

- `DaoGovernor.state(proposalId)`
- `DaoGovernor.proposalVotes(proposalId)`
- `DaoGovernor.proposalDetails(proposalId)`
- `DaoGovernor.proposalProposer(proposalId)`
- `DaoGovernor.proposalSnapshot(proposalId)`
- `DaoGovernor.proposalDeadline(proposalId)`

### Qué seguiría faltando incluso después

- `description` legible si no existe fuente indexada o metadata
- `executionEta` si no hay una forma directa clara desde timelock/cola

### Observación

- Esta es una de las vistas prioritarias a refactorizar.

---

## 5. Governance Create

### Ruta

- `/governance/create`

### Hook principal

- [frontend/src/hooks/useProposalComposerModel.ts](./frontend/src/hooks/useProposalComposerModel.ts)

### Estado

- `Parcial`

### Real desde contratos

- `DaoGovernor.proposalCount()`
- `DaoGovernor.proposalDetailsAt(index)`
- `DaoGovernor.state(proposalId)`
- `DaoGovernor.proposalVotes(proposalId)`
- `DaoGovernor.proposalDeadline(proposalId)`
- `GovernanceToken.getVotes(user)`
- `DaoGovernor.proposalThreshold()`
- `DaoGovernor.votingDelay()`
- `DaoGovernor.votingPeriod()`
- `delegate(...)` en el token de gobernanza

### Mockeado / pendiente

- submit real con `propose(...)`
- metadata del formulario de propuesta

### Qué debería usar

- `GovernanceToken.getVotes(user)`
- `DaoGovernor.proposalThreshold()`
- `DaoGovernor.propose(targets, values, calldatas, description)`

### Observación

- La delegación de votos ya funciona, pero la creación final de propuestas sigue pendiente.
- El composer ya no es un mock puro, pero todavía no cierra el flujo completo de `propose(...)`.

---

## 6. Guardians

### Ruta

- `/guardians`

### Hook principal

- [frontend/src/hooks/useGuardiansModel.ts](./frontend/src/hooks/useGuardiansModel.ts)

### Estado

- `Parcial-real`

### Real desde contratos

- `GuardianAdministrator.minStake()`
- `GuardianAdministrator.totalActiveGuardians()`
- `GuardianAdministrator.getGuardianDetail(user)`
- `GuardianBondEscrow.getApplicationTokenBalance()`
- `GuardianBondEscrow.guardianApplicationToken()`
- `ERC20.balanceOf(user)`
- `ERC20.allowance(user, escrow)`
- `ERC20.approve(...)`
- `GuardianAdministrator.applyGuardian()`

### Mockeado / pendiente

- `pendingApplications`

### Qué falta para cerrarla

- Indexación o lectura de eventos/propuestas para solicitudes pendientes

### Observación

- La aplicación como guardian ya tiene flujo real.
- La parte de red/analítica todavía no.

---

## 7. Vaults List

### Ruta

- `/vaults`

### Hook principal

- [frontend/src/hooks/useVaultsModel.ts](./frontend/src/hooks/useVaultsModel.ts)

### Estado

- `Real`

### Real desde contratos

- `VaultRegistry.totalVaults()`
- `VaultRegistry.getAllVaults()`
- `VaultRegistry.getVaultDetail(vault)`
- `GuardianAdministrator.totalActiveGuardians()`
- `ProtocolCore.isVaultDepositsPaused()`
- `ERC20.symbol()`

### Mockeado / pendiente

- No hay mock crítico.

### Observación

- De las vistas más sólidas hoy.

---

## 8. Vault Detail

### Ruta

- `/vaults/:vaultAddress`

### Hook principal

- [frontend/src/hooks/useVaultDetailModel.ts](./frontend/src/hooks/useVaultDetailModel.ts)

### Estado

- `Parcial`

### Real desde contratos

- `VaultRegistry.getVaultDetail(vault)`
- `ProtocolCore.isVaultDepositsPaused()`
- `RiskManager.executionPaused()`
- `ERC20.symbol()`
- `ERC20.decimals()`
- `vault.decimals()`
- `vault.balanceOf(user)`
- `vault.maxWithdraw(user)`
- `vault.maxRedeem(user)`
- `vault.previewRedeem(shares)`

### Mockeado / pendiente

- Write actions todavía no conectadas:
  - `deposit(...)`
  - `mint(...)`
  - `withdraw(...)`
  - `redeem(...)`
  - `executeStrategy(...)`

### Observación

- Excelente como vista de lectura/posición.
- Todavía incompleta como consola operativa del vault.

---

## 9. My Vault Positions

### Ruta

- `/vaults/positions`

### Hook principal

- [frontend/src/hooks/useMyVaultPositionsModel.ts](./frontend/src/hooks/useMyVaultPositionsModel.ts)

### Estado

- `Parcial-real`

### Real desde contratos

- Hoy prácticamente nada.

### Mockeado / pendiente

- `positions`
- `totalDepositedValue`
- `totalShareExposure`

### Qué falta para cerrarla

- Resolver posiciones por usuario recorriendo vaults
- y para `value`, una capa de pricing adicional

### Observación

- Aquí no alcanza solo con una llamada simple; requiere agregación.

---

## 10. Guardian Tools

### Ruta

- `/vaults/guardian-tools`

### Hook principal

- [frontend/src/hooks/useGuardianVaultToolsModel.ts](./frontend/src/hooks/useGuardianVaultToolsModel.ts)

### Estado

- `Parcial-real`

### Real desde contratos

- `ProtocolCore.isVaultAssetSupported(asset)`
- `VaultFactory.predictVaultAddress(guardian, asset)`
- `VaultFactory.isDeployed(guardian, asset)`
- `VaultRegistry.getVaultByAssetAndGuardian(asset, guardian)`
- `VaultFactory.createVault(asset, name, symbol)`

### Mockeado / pendiente

- No está mockeada en flujo principal.

### Limitación de contrato

- El frontend necesita lista base de assets por red porque `ProtocolCore` no expone una enumeración de vault assets soportados.

### Observación

- Funcionalmente útil, pero depende de catálogo local de assets.

---

## 11. Treasury Overview

### Ruta

- `/treasury`

### Hook principal

- [frontend/src/hooks/useTreasuryModel.ts](./frontend/src/hooks/useTreasuryModel.ts)

### Estado

- `Parcial-real`

### Real desde contratos

- `Treasury.nativeBalance()`
- `Treasury.erc20Balance(token)`
- `ProtocolCore.getSupportedGenesisTokens()`

### Mockeado / pendiente

- no hay mock fuerte en la tabla principal

### Qué debería usar

- balances reales de `USDT`, `USDC` y `nativeBalance()`
- clasificación derivada de `getSupportedGenesisTokens()`

### Qué seguiría faltando

- pricing/exposure agregado más fino
- lista configurable de tokens por red si quieren dejar de depender del catálogo local

### Observación

- La vista ya consume balances reales y clasificación real, pero todavía depende del catálogo local de assets conocidos.

---

## 12. Treasury Operations

### Ruta

- `/treasury/operations`

### Hook principal

- [frontend/src/hooks/useTreasuryOperationsModel.ts](./frontend/src/hooks/useTreasuryOperationsModel.ts)

### Estado

- `Parcial-real`

### Real desde contratos

- `ProtocolCore.getSupportedGenesisTokens()`
- `Treasury.withdrawDaoERC20(...)`
- `Treasury.withdrawNotAssetDaoERC20(...)`

### Mockeado / pendiente

- `withdrawDaoNative(...)`

### Limitación de contrato

- También depende de lista base de tokens conocidos por red para presentar opciones.

### Observación

- Para ERC20 está bastante bien.
- Para nativo aún no.

---

## 13. Operations

### Ruta

- `/operations`

### Hook principal

- [frontend/src/hooks/useOperationsModel.ts](./frontend/src/hooks/useOperationsModel.ts)

### Estado

- `Parcial-real`

### Real desde contratos

- `ProtocolCore.isVaultCreationPaused()`
- `ProtocolCore.isVaultDepositsPaused()`
- `ProtocolCore.getSupportedGenesisTokens()`
- `VaultFactory.router()`
- `VaultFactory.core()`
- `VaultFactory.guardianAdministrator()`
- `VaultFactory.vaultRegistry()`
- `Treasury.protocolCore()`

### Writes reales desde la vista

- `ProtocolCore.pauseVaultCreation()`
- `ProtocolCore.unpauseVaultCreation()`
- `ProtocolCore.pauseVaultDeposits()`
- `ProtocolCore.unpauseVaultDeposits()`
- `ProtocolCore.setSupportedVaultAsset(asset, allowed)`
- `ProtocolCore.setSupportedGenesisTokens(address[])`
- `VaultFactory.setRouter(...)`
- `VaultFactory.setCore(...)`
- `VaultFactory.setGuardianAdministrator(...)`
- `VaultFactory.setVaultRegistry(...)`
- `Treasury.setProtocolCore(...)`

### Mockeado / pendiente

- No hay mock fuerte en la operación principal.

### Limitación de contrato

- Conteo de vault assets soportados depende de assets conocidos por red, porque `ProtocolCore` no enumera ese conjunto.

### Observación

- Buena consola operativa.

---

## 14. Risk

### Ruta

- `/risk`

### Hook principal

- [frontend/src/hooks/useRiskModel.ts](./frontend/src/hooks/useRiskModel.ts)

### Estado

- `Parcial-real`

### Real desde contratos

- `RiskManager.executionPaused()`
- `RiskManager.getAssetConfig(asset)`
- `RiskManager.isAssetHealthy(asset)`
- `RiskManager.getValidatedPrice(asset)`
- `RiskManager.pauseAdapterExecution()`
- `RiskManager.unpauseAdapterExecution()`
- `RiskManager.setAssetConfig(...)`

### Mockeado / pendiente

- No está mockeada la tabla principal, pero no descubre assets sola.

### Limitación de contrato

- `RiskManager` no expone enumeración de assets configurados.
- El frontend depende de assets conocidos por red.

### Observación

- Muy buena base, pero limitada por el contrato.

---

## 15. Admin

### Ruta

- `/admin`

### Hook principal

- [frontend/src/hooks/useAdminModel.ts](./frontend/src/hooks/useAdminModel.ts)

### Estado

- `Parcial-real`

### Real desde contratos

- `ProtocolCore.isVaultCreationPaused()`
- `ProtocolCore.isVaultDepositsPaused()`
- `RiskManager.executionPaused()`
- `GenesisBonding.isFinalized()`
- `Treasury.protocolCore()`
- `GuardianAdministrator.minStake()`
- `GuardianAdministrator.totalActiveGuardians()`
- `GuardianBondEscrow.getApplicationTokenBalance()`
- `GuardianBondEscrow.guardianApplicationToken()`
- `VaultFactory.router()`
- `VaultFactory.core()`
- `VaultFactory.guardianAdministrator()`
- `VaultFactory.vaultRegistry()`
- `VaultRegistry.getAllVaults()`
- `DaoGovernor.proposalThreshold()`
- `DaoGovernor.votingDelay()`
- `DaoGovernor.votingPeriod()`

### Mockeado / pendiente

- No hay mock fuerte; la vista está alimentada por reads reales y direcciones de despliegue del entorno.

### Qué debería usar

- `ProtocolCore.isVaultCreationPaused()`
- `ProtocolCore.isVaultDepositsPaused()`
- `RiskManager.executionPaused()`
- `GenesisBonding.isFinalized()`
- `Treasury.protocolCore()`
- `GuardianAdministrator.bondEscrow()`
- addresses centralizadas por red

### Observación

- Ya no es conceptual: consume direcciones de despliegue reales del entorno y reads on-chain para diagnóstico.
- Sigue limitada por la red activa y por las direcciones disponibles en `deployments`.
- El panel ahora es útil como consola de diagnóstico, no solo como inventario.

---

## Mapa de Prioridad

### Alta prioridad

- `governance/:proposalId`
- `governance/create`
- `vaults/positions`

### Media prioridad

- `admin`
- `treasury` refinamientos
- `dashboard.activity`
- completar writes en `vault detail`

### Baja prioridad

- refinamientos analíticos como `bonding.totalPurchases`
- contadores derivados que requieren indexación

---

## Dependencias de Indexación / Eventos

Estas piezas no se resuelven bien solo con `view`:

- actividad del dashboard
- pending guardian applications
- compras históricas de bonding por usuario
- metadata legible de proposals
- historial / valor agregado de posiciones
- algunos resúmenes operativos/admin

---

## Recomendación de trabajo

Orden sugerido:

1. Conectar `Proposal Detail`
2. Conectar `Proposal Composer`
3. Conectar `Treasury Overview`
4. Conectar `Vault Positions`
5. Definir qué parte requiere subgraph/indexador
