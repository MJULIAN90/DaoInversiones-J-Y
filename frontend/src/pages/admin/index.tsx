import {
  Activity,
  Blocks,
  CheckCircle2,
  Database,
  Shield,
  Wrench,
} from "lucide-react";
import { useAdminModel } from "@/hooks/useAdminModel";

export default function AdminPage() {
  const { metrics, contracts, diagnostics, capabilities } = useAdminModel();

  return (
    <div className="space-y-8">
      <section className="rounded-3xl bg-gradient-to-r from-primary to-primary-light px-8 py-10 text-white shadow-card">
        <p className="text-xs font-semibold uppercase tracking-[0.2em] text-blue-100">
          Admin Console
        </p>

        <h1 className="mt-4 text-3xl font-semibold leading-tight lg:text-4xl">
          Review contract topology, protocol diagnostics and administrative
          control awareness across the full system.
        </h1>

        <p className="mt-4 max-w-3xl text-sm leading-7 text-blue-50 lg:text-base">
          Administrative visibility should clarify contract references,
          capability boundaries and upgrade-aware infrastructure without exposing
          unnecessary operational ambiguity.
        </p>

        <div className="mt-8 grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
          <HeroMetric label="Contracts Tracked" value={String(metrics.contractsTracked)} />
          <HeroMetric label="Upgradeable Systems" value={String(metrics.upgradeableSystems)} />
          <HeroMetric label="Diagnostics" value={metrics.diagnostics} />
          <HeroMetric label="Admin Posture" value={metrics.adminPosture} />
        </div>
      </section>

      <section className="grid gap-5 md:grid-cols-2 xl:grid-cols-4">
        <MetricCard
          title="Contract Registry"
          value="Mapped"
          subtitle="Core, governance, guardian and vault contracts are surfaced."
          icon={<Database className="h-5 w-5" />}
        />
        <MetricCard
          title="Capabilities View"
          value="Derived"
          subtitle="Admin-facing access should be based on capabilities, not raw UI checks."
          icon={<Shield className="h-5 w-5" />}
        />
        <MetricCard
          title="Upgradeable Awareness"
          value="Visible"
          subtitle="Upgradeable infrastructure is identified separately from static contracts."
          icon={<Wrench className="h-5 w-5" />}
        />
        <MetricCard
          title="Protocol Diagnostics"
          value="Observed"
          subtitle="Global state signals remain centralized for review."
          icon={<Activity className="h-5 w-5" />}
        />
      </section>

      <section className="grid gap-6 xl:grid-cols-[1.1fr,0.9fr]">
        <div className="card">
          <div className="card-header">Protocol Contract Registry</div>

          <div className="card-content space-y-6">
            <ContractGroup
              title="Core Contracts"
              items={contracts.filter((contract) => contract.group === "Core Contracts")}
            />
            <ContractGroup
              title="Governance Contracts"
              items={contracts.filter((contract) => contract.group === "Governance Contracts")}
            />
            <ContractGroup
              title="Guardian Contracts"
              items={contracts.filter((contract) => contract.group === "Guardian Contracts")}
            />
            <ContractGroup
              title="Vault Infrastructure"
              items={contracts.filter((contract) => contract.group === "Vault Infrastructure")}
            />
          </div>
        </div>

        <div className="space-y-6">
          <div className="card">
            <div className="card-header">Role & Capability Overview</div>

            <div className="card-content space-y-4">
              <CapabilityRow
                title="Treasury Operations"
                status="Restricted"
                tone="warning"
              />
              <CapabilityRow
                title="Protocol Controls"
                status="Manager / Emergency"
                tone="neutral"
              />
              <CapabilityRow
                title="Risk Controls"
                status="Protected"
                tone="warning"
              />
              <CapabilityRow
                title="Guardian Operations"
                status="Role-Derived"
                tone="success"
              />

              <div className="rounded-2xl border border-border bg-gray-50 px-4 py-4">
                <p className="text-sm font-medium text-text-primary">
                  Capability Model
                </p>
                <p className="mt-1 text-sm leading-6 text-text-secondary">
                  Administrative UI should consume derived capabilities from a
                  protocol session layer instead of directly exposing role checks
                  inside individual components.
                </p>
                <p className="mt-3 text-sm text-text-secondary">
                  Admin console access:{" "}
                  <span className="font-medium text-text-primary">
                    {capabilities.canAccessAdminConsole ? "Enabled" : "Restricted"}
                  </span>
                </p>
              </div>
            </div>
          </div>

          <div className="card">
            <div className="card-header">Upgradeable Infrastructure</div>

            <div className="card-content space-y-4">
              <UpgradeRow
                title="ProtocolCore"
                description="UUPS upgradeable core infrastructure."
              />
              <UpgradeRow
                title="RiskManager"
                description="Upgradeable risk validation and execution safety layer."
              />
              <UpgradeRow
                title="StrategyRouter"
                description="Upgradeable routing layer for strategy execution."
              />

              <div className="rounded-2xl border border-border bg-yellow-50 px-4 py-4">
                <p className="text-sm font-medium text-yellow-800">
                  Upgrade Awareness
                </p>
                <p className="mt-1 text-sm leading-6 text-yellow-700">
                  Upgradeable systems should be clearly identified and surfaced
                  separately from static infrastructure.
                </p>
              </div>
            </div>
          </div>
        </div>
      </section>

      <section className="card">
        <div className="card-header">Diagnostic Summary</div>

        <div className="card-content grid gap-5 lg:grid-cols-2 xl:grid-cols-3">
          {diagnostics.map((item) => (
            <DiagnosticCard
              key={item.title}
              title={item.title}
              value={item.value}
              subtitle={item.subtitle}
              tone={item.tone}
            />
          ))}
        </div>
      </section>
    </div>
  );
}

function HeroMetric({
  label,
  value,
}: {
  label: string;
  value: string;
}) {
  return (
    <div className="rounded-2xl bg-white/10 px-4 py-4 backdrop-blur">
      <p className="text-sm text-blue-50">{label}</p>
      <p className="mt-2 text-xl font-semibold text-white">{value}</p>
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

function ContractGroup({
  title,
  items,
}: {
  title: string;
  items: Array<{ name: string; address: string }>;
}) {
  return (
    <div>
      <div className="mb-3 flex items-center gap-2">
        <Blocks className="h-4 w-4 text-primary" />
        <h3 className="text-sm font-semibold text-text-primary">{title}</h3>
      </div>

      <div className="space-y-3">
        {items.map((item) => (
          <div
            key={item.name}
            className="flex items-center justify-between rounded-2xl border border-border px-4 py-4"
          >
            <div>
              <p className="text-sm font-medium text-text-primary">{item.name}</p>
              <p className="mt-1 text-sm text-text-secondary">{item.address}</p>
            </div>
            <CheckCircle2 className="h-5 w-5 text-success" />
          </div>
        ))}
      </div>
    </div>
  );
}

function CapabilityRow({
  title,
  status,
  tone,
}: {
  title: string;
  status: string;
  tone: "success" | "warning" | "neutral";
}) {
  return (
    <div className="flex items-center justify-between rounded-2xl border border-border px-4 py-4">
      <p className="text-sm font-medium text-text-primary">{title}</p>
      <span
        className={[
          "rounded-full px-3 py-1 text-xs font-medium",
          tone === "success" && "bg-green-100 text-green-700",
          tone === "warning" && "bg-yellow-100 text-yellow-700",
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

function UpgradeRow({
  title,
  description,
}: {
  title: string;
  description: string;
}) {
  return (
    <div className="rounded-2xl border border-border px-4 py-4">
      <p className="text-sm font-semibold text-text-primary">{title}</p>
      <p className="mt-1 text-sm leading-6 text-text-secondary">{description}</p>
    </div>
  );
}

function DiagnosticCard({
  title,
  value,
  subtitle,
  tone,
}: {
  title: string;
  value: string;
  subtitle: string;
  tone: "success" | "warning" | "neutral";
}) {
  return (
    <div className="rounded-2xl border border-border bg-gray-50 px-5 py-5">
      <div className="flex items-center justify-between">
        <p className="text-sm font-medium text-text-secondary">{title}</p>
        <span
          className={[
            "rounded-full px-3 py-1 text-xs font-medium",
            tone === "success" && "bg-green-100 text-green-700",
            tone === "warning" && "bg-yellow-100 text-yellow-700",
            tone === "neutral" && "bg-gray-100 text-gray-700",
          ]
            .filter(Boolean)
            .join(" ")}
        >
          {value}
        </span>
      </div>
      <p className="mt-4 text-sm leading-6 text-text-secondary">{subtitle}</p>
    </div>
  );
}