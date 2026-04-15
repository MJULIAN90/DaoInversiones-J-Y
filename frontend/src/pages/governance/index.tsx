import { ArrowRight, Clock3, Landmark, Vote } from "lucide-react";
import { useGovernanceModel } from "@/hooks/useGovernanceModel";
import { Link } from "react-router-dom";

export default function GovernancePage() {
  const { config, metrics, proposals, user, capabilities } =
    useGovernanceModel();

  return (
    <div className="space-y-8">
      <section className="rounded-3xl bg-gradient-to-r from-primary to-primary-light px-8 py-10 text-white shadow-card">
        <p className="text-xs font-semibold uppercase tracking-[0.2em] text-blue-100">
          Governance Layer
        </p>

        <h1 className="mt-4 text-3xl font-semibold leading-tight lg:text-4xl">
          Protocol Governance
        </h1>

        <p className="mt-4 max-w-2xl text-sm leading-7 text-blue-50 lg:text-base">
          Manage protocol decisions through token-based governance and
          timelocked execution.
        </p>

        <div className="mt-8 grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
          <HeroMetric
            label="Proposal Threshold"
            value={config.proposalThreshold}
          />
          <HeroMetric label="Voting Delay" value={config.votingDelay} />
          <HeroMetric label="Voting Period" value={config.votingPeriod} />
          <HeroMetric label="Execution Delay" value={config.executionDelay} />
        </div>
      </section>

      <section className="grid gap-5 md:grid-cols-2 xl:grid-cols-4">
        <MetricCard
          title="Active Proposals"
          value={String(metrics.activeProposals)}
          subtitle="Currently under governance review"
          icon={<Vote className="h-5 w-5" />}
        />
        <MetricCard
          title="Queued Proposals"
          value={String(metrics.queuedProposals)}
          subtitle="Awaiting timelock execution"
          icon={<Clock3 className="h-5 w-5" />}
        />
        <MetricCard
          title="Executed Proposals"
          value={String(metrics.executedProposals)}
          subtitle="Successfully completed governance actions"
          icon={<Landmark className="h-5 w-5" />}
        />
        <MetricCard
          title="Governance Participation"
          value={metrics.participation}
          subtitle="Illustrative participation baseline"
          icon={<Vote className="h-5 w-5" />}
        />
      </section>

      <section className="grid gap-6 xl:grid-cols-[1.15fr,0.85fr]">
        <div className="card">
          <div className="card-header">Proposal List</div>

          <div className="overflow-x-auto">
            <table className="min-w-full border-collapse">
              <thead>
                <tr className="border-b border-border bg-gray-50 text-left">
                  <th className="px-6 py-4 text-xs font-semibold uppercase tracking-[0.14em] text-text-secondary">
                    Proposal ID
                  </th>
                  <th className="px-6 py-4 text-xs font-semibold uppercase tracking-[0.14em] text-text-secondary">
                    Title
                  </th>
                  <th className="px-6 py-4 text-xs font-semibold uppercase tracking-[0.14em] text-text-secondary">
                    Status
                  </th>
                  <th className="px-6 py-4 text-xs font-semibold uppercase tracking-[0.14em] text-text-secondary">
                    Votes
                  </th>
                  <th className="px-6 py-4 text-xs font-semibold uppercase tracking-[0.14em] text-text-secondary">
                    End Time
                  </th>
                  <th className="px-6 py-4 text-xs font-semibold uppercase tracking-[0.14em] text-text-secondary">
                    Action
                  </th>
                </tr>
              </thead>

              <tbody>
                {proposals.map((proposal) => (
                  <tr key={proposal.id} className="border-b border-border">
                    <td className="px-6 py-4 text-sm font-medium text-text-primary">
                      {proposal.id}
                    </td>
                    <td className="px-6 py-4 text-sm text-text-primary">
                      {proposal.title}
                    </td>
                    <td className="px-6 py-4">
                      <ProposalStatus status={proposal.status} />
                    </td>
                    <td className="px-6 py-4 text-sm text-text-secondary">
                      {proposal.votes}
                    </td>
                    <td className="px-6 py-4 text-sm text-text-secondary">
                      {proposal.endDate}
                    </td>
                    <td className="px-6 py-4">
                      <Link
                        to={`/governance/${proposal.id}`}
                        className="inline-flex items-center gap-2 text-sm font-medium text-primary hover:underline"
                      >
                        View Details
                        <ArrowRight className="h-4 w-4" />
                      </Link>
                      {/* TODO: navegar a /governance/proposals/:proposalId */}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          {proposals.length === 0 && (
            <div className="card-content">
              <p className="text-sm text-text-secondary">
                No proposals available.
              </p>
            </div>
          )}
        </div>

        <div className="space-y-6">
          <div className="card">
            <div className="card-header">Proposal Lifecycle</div>

            <div className="card-content space-y-4">
              <LifecycleStep
                title="Created"
                description="A proposal is submitted by an eligible governance participant."
              />
              <LifecycleStep
                title="Voting Delay"
                description="The proposal waits until voting becomes active."
              />
              <LifecycleStep
                title="Active Voting"
                description="Governance token holders participate in the decision."
              />
              <LifecycleStep
                title="Queued"
                description="Successful proposals enter the timelock delay period."
              />
              <LifecycleStep
                title="Executed"
                description="Approved and queued proposals are executed onchain."
              />
            </div>
          </div>

          <div className="card">
            <div className="card-header">Create Proposal</div>

            <div className="card-content space-y-4">
              <p className="text-sm leading-7 text-text-secondary">
                Submit protocol changes through governed proposals once the
                minimum voting threshold is met.
              </p>

              <div className="rounded-2xl border border-border bg-gray-50 px-4 py-4">
                <p className="text-sm text-text-secondary">
                  Eligibility Status
                </p>
                <p className="mt-2 text-sm font-medium text-text-primary">
                  {user.meetsProposalThreshold
                    ? "You meet the proposal threshold."
                    : "You need a minimum voting power to submit proposals."}
                </p>
                <p className="mt-2 text-sm text-text-secondary">
                  Current voting power: {user.votingPower}
                </p>
              </div>

              <Link
                to="/governance/create"
                className={[
                  "block w-full rounded-lg px-4 py-2 text-center text-sm font-medium transition",
                  capabilities.canCreateProposal
                    ? "bg-primary text-white hover:bg-primary-hover"
                    : "cursor-not-allowed bg-primary/50 text-white pointer-events-none opacity-50",
                ].join(" ")}
              >
                Open Proposal Composer
              </Link>

              {/* TODO: navegar a /governance/create */}
              {/* TODO: conectar propose(...) desde la vista composer */}
            </div>
          </div>
        </div>
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

        <p className="mt-5 text-3xl font-semibold text-text-primary">{value}</p>
        <p className="mt-2 text-sm leading-6 text-text-secondary">{subtitle}</p>
      </div>
    </div>
  );
}

function ProposalStatus({ status }: { status: string }) {
  const className =
    status === "Active"
      ? "badge-success"
      : status === "Queued"
        ? "badge-warning"
        : status === "Executed"
          ? "rounded-full bg-gray-100 px-3 py-1 text-xs font-medium text-gray-700"
          : status === "Pending"
            ? "rounded-full bg-gray-100 px-3 py-1 text-xs font-medium text-gray-700"
            : "badge-danger";

  return <span className={className}>{status}</span>;
}

function LifecycleStep({
  title,
  description,
}: {
  title: string;
  description: string;
}) {
  return (
    <div className="flex gap-4">
      <div className="mt-1 flex h-8 w-8 items-center justify-center rounded-full bg-blue-50 text-sm font-semibold text-primary">
        •
      </div>

      <div>
        <h3 className="text-sm font-semibold text-text-primary">{title}</h3>
        <p className="mt-1 text-sm leading-6 text-text-secondary">
          {description}
        </p>
      </div>
    </div>
  );
}
