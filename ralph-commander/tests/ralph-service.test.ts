import { describe, it, expect, mock } from "bun:test";

// Mock fs/promises BEFORE importing the service
const mockReadFile = mock(async (path: string) => {
  if (path.includes("missing")) {
    const err = new Error("File not found");
    (err as any).code = "ENOENT";
    throw err;
  }
  
  if (path.includes("invalid")) {
    return "INVALID CONTENT -- NO SEPARATORS";
  }

  if (path.includes("@fix_plan.md")) {
    return `# Test Plan
- [x] **Phase 1: Task 1**
    - [x] Subtask 1.1
    - [ ] Subtask 1.2
- [ ] **Phase 2: Task 2**
    - [ ] Subtask 2.1
`;
  }

  return `---
active: true
iteration: 5
max_iterations: 10
completion_promise: "DONE"
started_at: "2026-01-30T12:00:00Z"
---

This is the prompt body.`;
});

mock.module("fs/promises", () => ({
  readFile: mockReadFile,
  stat: mock(async () => ({ size: 100 })),
  open: mock(async () => ({ read: mock(), close: mock() }))
}));

import { getRalphStatus, getRalphTasks } from "../src/server/services/ralph";

describe("Ralph Service", () => {
  it("should parse a valid status file", async () => {
    const status = await getRalphStatus();
    expect(status).not.toBeNull();
    expect(status?.active).toBe(true);
    expect(status?.iteration).toBe(5);
  });

  it("should parse tasks from @fix_plan.md", async () => {
    // Force the mock to return exactly what we want for this test
    mockReadFile.mockImplementation(async (path: string) => {
        if (path.endsWith("@fix_plan.md")) {
            return `# Test Plan
- [x] **Phase 1: Task 1**
    - [x] Subtask 1.1
    - [ ] Subtask 1.2
- [ ] **Phase 2: Task 2**
    - [ ] Subtask 2.1
`;
        }
        return "";
    });

    const tasks = await getRalphTasks();
    expect(tasks.length).toBe(3);
    expect(tasks[0].description).toBe("Subtask 1.1");
    expect(tasks[0].completed).toBe(true);
    expect(tasks[2].description).toBe("Subtask 2.1");
  });
});
