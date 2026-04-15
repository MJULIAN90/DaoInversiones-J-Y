import { ArrowRight, BriefcaseBusiness, Coins, Wallet } from "lucide-react";
import { useMyVaultPositionsModel } from "@/hooks/useMyVaultPositionsModel";
import { Link } from "react-router-dom";

export default function MyPositionsPage() {
  const { positions, totalDepositedValue, totalShareExposure } =
    useMyVaultPositionsModel();

  return (
    <div className="space-y-8">
      <section className="rounded-3xl bg-gradient-to-r from-primary to-primary-light px-8 py-10 text-white shadow-card">
        <p className="text-xs font-semibold uppercase tracking-[0.2em] text-blue-100">
          My Vault Positions
        </p>

        <h1 className="mt-4 text-3xl font-semibold leading-tight lg:text-4xl">
          Review your deposited assets, share exposure and vault-linked
          positions.
        </h1>

        <p className="mt-4 max-w-3xl text-sm leading-7 text-blue-50 lg:text-base">
          Personal vault positions should remain visible independently from
          operational controls and provide a clear path to vault detail views.
        </p>

        <div className="mt-8 grid gap-4 sm:grid-cols-2 xl:grid-cols-3">
          <HeroMetric
            label="Total Deposited Value"
            value={totalDepositedValue}
          />
          <HeroMetric label="Share Exposure" value={totalShareExposure} />
          <HeroMetric
            label="Active Positions"
            value={String(positions.length)}
          />
        </div>
      </section>

      <section className="grid gap-5 md:grid-cols-2 xl:grid-cols-3">
        <MetricCard
          title="Deposited Value"
          value={totalDepositedValue}
          subtitle="Aggregate value across tracked vault positions"
          icon={<Wallet className="h-5 w-5" />}
        />
        <MetricCard
          title="Share Exposure"
          value={totalShareExposure}
          subtitle="Total share balance across tracked vaults"
          icon={<Coins className="h-5 w-5" />}
        />
        <MetricCard
          title="Vault Participation"
          value={String(positions.length)}
          subtitle="Tracked vault positions for the connected account"
          icon={<BriefcaseBusiness className="h-5 w-5" />}
        />
      </section>

      <section className="card">
        <div className="card-header">Position Table</div>

        <div className="overflow-x-auto">
          <table className="min-w-full border-collapse">
            <thead>
              <tr className="border-b border-border bg-gray-50 text-left">
                <th className="px-6 py-4 text-xs font-semibold uppercase tracking-[0.14em] text-text-secondary">
                  Vault
                </th>
                <th className="px-6 py-4 text-xs font-semibold uppercase tracking-[0.14em] text-text-secondary">
                  Asset
                </th>
                <th className="px-6 py-4 text-xs font-semibold uppercase tracking-[0.14em] text-text-secondary">
                  Deposited
                </th>
                <th className="px-6 py-4 text-xs font-semibold uppercase tracking-[0.14em] text-text-secondary">
                  Shares
                </th>
                <th className="px-6 py-4 text-xs font-semibold uppercase tracking-[0.14em] text-text-secondary">
                  Value
                </th>
                <th className="px-6 py-4 text-xs font-semibold uppercase tracking-[0.14em] text-text-secondary">
                  Action
                </th>
              </tr>
            </thead>

            <tbody>
              {positions.map((position) => (
                <tr
                  key={position.vaultAddress}
                  className="border-b border-border"
                >
                  <td className="px-6 py-4 text-sm font-medium text-text-primary">
                    {position.vaultAddress}
                  </td>
                  <td className="px-6 py-4 text-sm text-text-secondary">
                    {position.asset}
                  </td>
                  <td className="px-6 py-4 text-sm text-text-secondary">
                    {position.deposited}
                  </td>
                  <td className="px-6 py-4 text-sm text-text-secondary">
                    {position.shares}
                  </td>
                  <td className="px-6 py-4 text-sm text-text-secondary">
                    {position.value}
                  </td>
                  <td className="px-6 py-4">
                    <Link
                      to={`/vaults/${position.vaultAddress}`}
                      className="inline-flex items-center gap-2 text-sm font-medium text-primary hover:underline"
                    >
                      View Vault
                      <ArrowRight className="h-4 w-4" />
                    </Link>
                    {/* TODO: navegar a /vaults/:vaultAddress */}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        {positions.length === 0 && (
          <div className="card-content">
            <p className="text-sm text-text-secondary">
              No vault positions available for the connected account.
            </p>
          </div>
        )}
      </section>
    </div>
  );
}

function HeroMetric({ label, value }: { label: string; value: string }) {
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

        <p className="mt-5 text-2xl font-semibold text-text-primary">{value}</p>
        <p className="mt-2 text-sm leading-6 text-text-secondary">{subtitle}</p>
      </div>
    </div>
  );
}
