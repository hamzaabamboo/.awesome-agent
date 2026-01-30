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

export async function getRalphStatus(): Promise<RalphStatus | null> {
  try {
    const content = await readFile(STATUS_FILE_PATH, "utf-8");
    const parts = content.split("---");
    
    if (parts.length < 3) return null;

    const frontmatter = parts[1];
    const body = parts.slice(2).join("---").trim();
    
    const state = yaml.load(frontmatter) as any;
    
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
    return null;
  }
}
