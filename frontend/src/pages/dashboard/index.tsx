import { ArrowRight, Building2, Coins, Landmark, Users } from "lucide-react";
import { Link } from "react-router-dom";
import { useDashboardModel } from "@/hooks/useDashboardModel";

export default function DashboardPage() {
  const { metrics, status, activity, capabilities } = useDashboardModel();

  return (
    <div className="space-y-8">
      <section className="overflow-hidden rounded-3xl bg-gradient-to-r from-primary to-primary-light text-white shadow-card">
        <div className="grid gap-8 px-8 py-10 lg:grid-cols-[1.4fr,0.8fr]">
          <div>
            <p className="text-xs font-semibold uppercase tracking-[0.22em] text-blue-100">
              J&amp;Y Protocol
            </p>

            <h1 className="mt-4 max-w-3xl text-3xl font-semibold leading-tight lg:text-4xl">
              Institutional DeFi infrastructure for governed treasury
              operations, guardian-led vault deployment and risk-aware
              execution.
            </h1>

            <p className="mt-4 max-w-2xl text-sm leading-7 text-blue-50/95 lg:text-base">
              A unified operating environment for capital formation, governance
              control, treasury visibility and vault lifecycle management.
            </p>

            <div className="mt-8 flex flex-wrap gap-3">
              <QuickActionButton
                label="Explore Vaults"
                disabled={false}
                to="/vaults"
              />
              <QuickActionButton
                label="Review Governance"
                disabled={false}
                to="/governance"
              />
              <QuickActionButton
                label="Apply as Guardian"
                disabled={!capabilities.canApplyAsGuardian}
                to="/guardians"
              />
            </div>

            {/* TODO: conectar estos botones con navegación real o acciones de producto */}
          </div>

          <div className="rounded-3xl bg-white/12 p-6 backdrop-blur">
            <p className="text-xs font-semibold uppercase tracking-[0.2em] text-blue-100">
              Protocol Status
            </p>

            <div className="mt-5 space-y-4">
              <StatusRow
                label="Network"
                value={status.network}
                tone="neutral"
              />
              <StatusRow
                label="Bonding"
                value={formatBondingStatus(status.bonding)}
                tone={status.bonding === "active" ? "success" : "warning"}
              />
              <StatusRow
                label="Vault Creation"
                value={formatEnabledStatus(status.vaultCreation)}
                tone={status.vaultCreation === "enabled" ? "success" : "danger"}
              />
              <StatusRow
                label="Vault Deposits"
                value={formatEnabledStatus(status.deposits)}
                tone={status.deposits === "enabled" ? "success" : "danger"}
              />
              <StatusRow
                label="Execution Engine"
                value={formatExecutionStatus(status.execution)}
                tone={status.execution === "monitoring" ? "warning" : "danger"}
              />
            </div>
          </div>
        </div>
      </section>

      <section className="grid gap-5 md:grid-cols-2 xl:grid-cols-4">
        <MetricCard
          title="Total Vault Count"
          value={String(metrics.totalVaults)}
          subtitle="Across active and tracked protocol vaults"
          icon={<Building2 className="h-5 w-5" />}
        />
        <MetricCard
          title="Treasury Snapshot"
          value={metrics.treasuryValue}
          subtitle="Native and ERC20 treasury visibility"
          icon={<Landmark className="h-5 w-5" />}
        />
        <MetricCard
          title="Proposal Threshold"
          value={metrics.proposalThreshold}
          subtitle="Minimum governance threshold reference"
          icon={<Coins className="h-5 w-5" />}
        />
        <MetricCard
          title="Guardian Network"
          value={String(metrics.guardianCount)}
          subtitle="Active guardian participants"
          icon={<Users className="h-5 w-5" />}
        />
      </section>

      <section className="grid gap-6 xl:grid-cols-[1.1fr,0.9fr]">
        <div className="card">
          <div className="card-header">Protocol Overview</div>

          <div className="card-content space-y-4">
            <OverviewRow
              title="Bonding Program"
              description="Governance token acquisition program status"
              status={formatBondingStatus(status.bonding)}
              tone={status.bonding === "active" ? "success" : "warning"}
            />
            <OverviewRow
              title="Governance Layer"
              description="Proposal threshold, timing and execution controls"
              status="Operational"
              tone="success"
            />
            <OverviewRow
              title="Vault Infrastructure"
              description="Vault registration and guardian-linked deployment"
              status={
                status.vaultCreation === "enabled" ? "Healthy" : "Restricted"
              }
              tone={status.vaultCreation === "enabled" ? "success" : "warning"}
            />
            <OverviewRow
              title="Treasury Layer"
              description="Reserve visibility and controlled withdrawals"
              status="Visible"
              tone="neutral"
            />
            <OverviewRow
              title="Guardian Network"
              description="Bonded operator lifecycle and application flow"
              status="Monitoring"
              tone="warning"
            />
            <OverviewRow
              title="Risk Monitoring"
              description="Execution safety and asset validation checks"
              status={formatExecutionStatus(status.execution)}
              tone={status.execution === "monitoring" ? "warning" : "danger"}
            />
          </div>
        </div>

        <div className="space-y-6">
          <div className="card">
            <div className="card-header">Recent Protocol Activity</div>

            <div className="card-content space-y-3">
              {activity.map((item) => (
                <ActivityItem
                  key={item.id}
                  title={item.title}
                  subtitle={item.description}
                />
              ))}
            </div>
          </div>

          <div className="card">
            <div className="card-header">Quick Actions</div>

            <div className="card-content grid gap-3">
              <QuickAction
                title="Buy Governance Tokens"
                description="Open the bonding program and review supported assets."
                to="/bonding"
              />
              <QuickAction
                title="Create Proposal"
                description="Review governance thresholds and submit a new proposal."
                to="/governance/create"
              />
              <QuickAction
                title="Open Vault Explorer"
                description="Browse vault infrastructure and view asset coverage."
                to="/vaults"
              />
              <QuickAction
                title="Review Treasury"
                description="Inspect balances and treasury composition."
                to="/treasury"
              />
            </div>

            {/* TODO:
              - deshabilitar o adaptar acciones según capabilities
              - conectar navegación hacia bonding / governance / vaults / treasury
            */}
          </div>
        </div>
      </section>

      <section className="grid gap-6 lg:grid-cols-2">
        <div className="card">
          <div className="card-header">Governance Snapshot</div>
          <div className="card-content grid gap-4 sm:grid-cols-3">
            <MiniStat label="Voting Delay" value="24h" />
            <MiniStat label="Voting Period" value="72h" />
            <MiniStat label="Execution Delay" value="48h" />

            {/* TODO: mover estos datos a useGovernanceModel o a un snapshot agregado */}
          </div>
        </div>

        <div className="card">
          <div className="card-header">Treasury Snapshot</div>
          <div className="card-content grid gap-4 sm:grid-cols-3">
            <MiniStat label="Native Balance" value="320 ETH" />
            <MiniStat label="Tracked ERC20" value="6 Assets" />
            <MiniStat label="Liquidity" value="Stable" />

            {/* TODO: mover estos datos a useTreasuryModel o a un snapshot agregado */}
          </div>
        </div>
      </section>
    </div>
  );
}

function MetricCard({
  title,
  value,
  subtitle,
  icon,
}: {
  title: string;
  value: string;
  subtitle: string;
  icon: React.ReactNode;
}) {
  return (
    <div className="card">
      <div className="card-content">
        <div className="flex items-center justify-between">
          <p className="text-sm font-medium text-text-secondary">{title}</p>
          <div className="rounded-xl bg-blue-50 p-2 text-primary">{icon}</div>
        </div>

        <p className="mt-5 text-3xl font-semibold text-text-primary">{value}</p>
        <p className="mt-2 text-sm leading-6 text-text-secondary">{subtitle}</p>
      </div>
    </div>
  );
}

function StatusRow({
  label,
  value,
  tone,
}: {
  label: string;
  value: string;
  tone: "success" | "warning" | "danger" | "neutral";
}) {
  return (
    <div className="flex items-center justify-between rounded-2xl bg-white/10 px-4 py-3">
      <p className="text-sm text-blue-50">{label}</p>
      <span
        className={[
          "rounded-full px-3 py-1 text-xs font-medium",
          tone === "success" && "bg-green-100 text-green-700",
          tone === "warning" && "bg-yellow-100 text-yellow-700",
          tone === "danger" && "bg-red-100 text-red-700",
          tone === "neutral" && "bg-white/20 text-white",
        ]
          .filter(Boolean)
          .join(" ")}
      >
        {value}
      </span>
    </div>
  );
}

function OverviewRow({
  title,
  description,
  status,
  tone,
}: {
  title: string;
  description: string;
  status: string;
  tone: "success" | "warning" | "danger" | "neutral";
}) {
  return (
    <div className="flex items-start justify-between gap-4 rounded-2xl border border-border px-4 py-4">
      <div>
        <h3 className="text-sm font-semibold text-text-primary">{title}</h3>
        <p className="mt-1 text-sm leading-6 text-text-secondary">
          {description}
        </p>
      </div>

      <span
        className={[
          "whitespace-nowrap rounded-full px-3 py-1 text-xs font-medium",
          tone === "success" && "bg-green-100 text-green-700",
          tone === "warning" && "bg-yellow-100 text-yellow-700",
          tone === "danger" && "bg-red-100 text-red-700",
          tone === "neutral" && "bg-gray-100 text-gray-700",
        ]
          .filter(Boolean)
          .join(" ")}
      >
        {status}
      </span>
    </div>
  );
}

function ActivityItem({
  title,
  subtitle,
}: {
  title: string;
  subtitle: string;
}) {
  return (
    <div className="rounded-2xl border border-border px-4 py-4">
      <h3 className="text-sm font-semibold text-text-primary">{title}</h3>
      <p className="mt-1 text-sm leading-6 text-text-secondary">{subtitle}</p>
    </div>
  );
}

function QuickAction({
  title,
  description,
  to,
}: {
  title: string;
  description: string;
  to: string;
}) {
  return (
    // TODO: REVISAR SI SI ES ASI?

    <Link
      to={to}
      className="flex items-center justify-between rounded-2xl border border-border px-4 py-4 text-left transition hover:border-primary/30 hover:bg-blue-50/40"
    >
      <div>
        <h3 className="text-sm font-semibold text-text-primary">{title}</h3>
        <p className="mt-1 text-sm leading-6 text-text-secondary">
          {description}
        </p>
      </div>
      <div className="rounded-xl bg-blue-50 p-2 text-primary">
        <ArrowRight className="h-4 w-4" />
      </div>
    </Link>
  );
}

function MiniStat({ label, value }: { label: string; value: string }) {
  return (
    <div className="rounded-2xl border border-border bg-gray-50 px-4 py-4">
      <p className="text-sm text-text-secondary">{label}</p>
      <p className="mt-2 text-xl font-semibold text-text-primary">{value}</p>
    </div>
  );
}

function QuickActionButton({
  label,
  disabled,
  to,
}: {
  label: string;
  disabled: boolean;
  to: string;
}) {
  if (disabled) {
    return (
      <button
        disabled
        className="cursor-not-allowed rounded-xl border border-white/20 bg-white/10 px-5 py-3 text-sm font-medium text-white/60"
      >
        {label}
      </button>
    );
  }

  return (
    <Link
      to={to}
      className="rounded-xl border border-white/30 bg-white/10 px-5 py-3 text-sm font-medium text-white transition hover:bg-white/20"
    >
      {label}
    </Link>
  );
}

function formatBondingStatus(value: "active" | "finalized") {
  return value === "active" ? "Active" : "Finalized";
}

function formatEnabledStatus(value: "enabled" | "paused") {
  return value === "enabled" ? "Enabled" : "Paused";
}

function formatExecutionStatus(value: "monitoring" | "paused") {
  return value === "monitoring" ? "Monitoring" : "Paused";
}
