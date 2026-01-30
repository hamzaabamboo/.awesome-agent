import { describe, it, expect, mock } from "bun:test";
mock.module("vike/server", () => ({ renderPage: mock(async () => ({ httpResponse: null })), createDevMiddleware: mock(async () => ({ devMiddleware: () => {} })) }));
import { app } from "../src/server/index";
import { writeFile, mkdir } from "fs/promises";
import { join } from "path";

describe("Status WebSocket Streaming", () => {
  const GEMINI_DIR = join(process.cwd(), ".gemini");
  const STATUS_FILE_PATH = join(GEMINI_DIR, "ralph-loop.local.md");

  it("should receive status updates via /ws", async () => {
    await mkdir(GEMINI_DIR, { recursive: true });
    
    // Initial state
    await writeFile(STATUS_FILE_PATH, "---\nactive: false\niteration: 0\n---\nInitial prompt");

    // Listen on a random port
    app.listen(0);
    const port = app.server?.port;
    const wsUrl = `ws://localhost:${port}/ws`;
    
    const promise = new Promise<any>((resolve, reject) => {
      const ws = new WebSocket(wsUrl);
      
      const timeout = setTimeout(() => {
        ws.close();
        app.stop();
        reject(new Error("WebSocket status update timeout"));
      }, 5000);

      ws.onmessage = (event) => {
        const msg = JSON.parse(event.data as string);
        if (msg.type === "status") {
          // We might get the initial status, we want the updated one
          if (msg.data.iteration === 99) {
            clearTimeout(timeout);
            ws.close();
            app.stop();
            resolve(msg.data);
          }
        }
      };

      ws.onerror = (err) => {
        clearTimeout(timeout);
        app.stop();
        reject(err);
      };
    });

    // Wait for subscription to be active
    await new Promise(r => setTimeout(r, 200));
    
    // Update status
    await writeFile(STATUS_FILE_PATH, "---\nactive: true\niteration: 99\n---\nUpdated prompt");

    const receivedData = await promise;
    expect(receivedData.iteration).toBe(99);
    expect(receivedData.active).toBe(true);
  });
});
