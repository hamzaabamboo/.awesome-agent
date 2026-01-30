import { join } from "path";
import { readFile } from "fs/promises";
import yaml from "js-yaml";

// We want to point to the root of the .awesome-agent repo
// Since the server runs in ralph-commander, process.cwd() is .awesome-agent/ralph-commander
const STATUS_FILE_PATH = join(process.cwd(), "..", ".gemini", "ralph-loop.local.md");

export interface RalphStatus {
  active: boolean;
  iteration: number;
  max_iterations: number;
  completion_promise: string;
  started_at: string;
  prompt?: string;
}

export class RalphServiceError extends Error {
  constructor(message: string, public code?: string) {
    super(message);
    this.name = "RalphServiceError";
  }
}

export async function getRalphStatus(): Promise<RalphStatus> {
  try {
    const content = await readFile(STATUS_FILE_PATH, "utf-8");
    const parts = content.split("---");
    
    if (parts.length < 3) {
      throw new RalphServiceError("Invalid status file format: missing frontmatter separators");
    }

    const frontmatter = parts[1];
    const body = parts.slice(2).join("---").trim();
    
    let state: any;
    try {
      state = yaml.load(frontmatter) as any;
    } catch (e) {
      throw new RalphServiceError("Invalid YAML frontmatter in status file");
    }
    
    return {
      active: state.active || false,
      iteration: state.iteration || 0,
      max_iterations: state.max_iterations || 0,
      completion_promise: state.completion_promise || "",
      started_at: state.started_at || "",
      prompt: body
    };
  } catch (error) {
    if ((error as any).code === 'ENOENT') {
      return { active: false, iteration: 0, max_iterations: 0, completion_promise: "", started_at: "", prompt: "" };
    }
    if (error instanceof RalphServiceError) {
      throw error;
    }
    throw new RalphServiceError(`Failed to read status: ${(error as Error).message}`, (error as any).code);
  }
}
