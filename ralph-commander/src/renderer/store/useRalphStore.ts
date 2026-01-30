import { create } from 'zustand';

export interface RalphStatus {
  active: boolean;
  iteration: number;
  max_iterations: number;
  completion_promise: string;
  started_at: string;
  prompt: string;
  agent?: string;
  model?: string;
  queries?: number;
  phase?: string;
  stats?: any;
}

export interface RalphTask {
  description: string;
  completed: boolean;
  phase?: string;
}

export interface RalphFile {
  status: string;
  path: string;
}

interface RalphState {
  status: RalphStatus | null;
  logs: string;
  tasks: RalphTask[];
  changedFiles: RalphFile[];
  
  // Actions
  setStatus: (status: RalphStatus) => void;
  appendLogs: (newLogs: string) => void;
  setLogs: (logs: string) => void;
  setTasks: (tasks: RalphTask[]) => void;
  setChangedFiles: (files: RalphFile[]) => void;
}

export const useRalphStore = create<RalphState>((set) => ({
  status: null,
  logs: '',
  tasks: [],
  changedFiles: [],

  setStatus: (status) => set({ status }),
  appendLogs: (newLogs) => set((state) => ({ logs: state.logs + newLogs })),
  setLogs: (logs) => set({ logs }),
  setTasks: (tasks) => set({ tasks }),
  setChangedFiles: (changedFiles) => set({ changedFiles }),
}));
