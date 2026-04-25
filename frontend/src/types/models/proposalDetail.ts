import type { ProtocolCapabilities } from "@/types/capabilities";

export type ProposalDetailStatus =
  | "Pending"
  | "Active"
  | "Succeeded"
  | "Defeated"
  | "Queued"
  | "Executed"
  | "Canceled";

export interface ProposalVoteBreakdown {
  forVotes: string;
  againstVotes: string;
  abstainVotes: string;
}

export interface ProposalTimelineItem {
  label: string;
  value: string;
}

export interface ProposalDetailAction {
  target: string;
  value: string;
  calldata: string;
}

export interface ProposalDetailData {
  id: string;
  title: string;
  status: ProposalDetailStatus;
  description: string;
  proposer: string;
  executionEta: string;
  votes: ProposalVoteBreakdown;
  timeline: ProposalTimelineItem[];
  actions: ProposalDetailAction[];
}

export interface ProposalDetailModel {
  proposal: ProposalDetailData;
  capabilities: ProtocolCapabilities;
}
