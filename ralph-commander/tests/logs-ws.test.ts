import { describe, it, expect, vi } from "vitest";

vi.mock("vike/server", () => ({
  renderPage: vi.fn(async () => ({ httpResponse: null })),
  createDevMiddleware: vi.fn(async () => ({ devMiddleware: () => {} }))
}));

import { app } from "../src/server/index";
import { appendFile, writeFile } from "fs/promises";
import { join } from "path";

describe("Logs WebSocket Streaming", () => {
  const LOG_FILE_PATH = join(process.cwd(), "ralph-runner.log");

  it("should receive log updates via /ws", async () => {
    // Ensure log file exists and is empty
    await writeFile(LOG_FILE_PATH, "initial\n");

    // Listen on a random port
    app.listen(0);
    const port = app.server?.port;
    const wsUrl = `ws://localhost:${port}/ws`;
    
    const promise = new Promise<string>((resolve, reject) => {
      const ws = new WebSocket(wsUrl);
      
      const timeout = setTimeout(() => {
        ws.close();
        app.stop();
        reject(new Error("WebSocket log update timeout"));
      }, 5000);

      ws.onopen = () => {
        // Wait a bit for subscription to be active
        setTimeout(async () => {
          await appendFile(LOG_FILE_PATH, "new log line\n");
        }, 100);
      };

      ws.onmessage = (event) => {
        const msg = JSON.parse(event.data as string);
        if (msg.type === "logs") {
          if (msg.data.includes("UNIQUE_LOG_LINE")) {
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
    await appendFile(LOG_FILE_PATH, "UNIQUE_LOG_LINE\n");

    const receivedData = await promise;
    expect(receivedData).toBe("UNIQUE_LOG_LINE\n");
  });
});
