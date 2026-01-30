import { describe, it, expect, mock, beforeAll } from "bun:test";
import { getRalphStatus } from "../src/server/services/ralph";

// Mock fs/promises
const mockReadFile = mock(async (path: string) => {
  if (path.includes("missing")) {
    const err = new Error("File not found");
    (err as any).code = "ENOENT";
    throw err;
  }
  
  if (path.includes("invalid")) {
    return "INVALID CONTENT -- NO SEPARATORS";
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
  readFile: mockReadFile
}));

describe("Ralph Service", () => {
  it("should parse a valid status file", async () => {
    // We need to trick the service into using a path that doesn't trigger our error mocks
    // Since the service uses process.cwd(), we can't easily change the path it reads 
    // without dependency injection or more complex mocking.
    // However, bun's module mocking should intercept the call.
    
    // NOTE: In a real scenario, we might refactor the service to accept a filepath.
    // For this test, assuming the mock works for the default path:
    const status = await getRalphStatus();
    
    expect(status).not.toBeNull();
    expect(status?.active).toBe(true);
    expect(status?.iteration).toBe(5);
    expect(status?.prompt).toBe("This is the prompt body.");
  });
});
