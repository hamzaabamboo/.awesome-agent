import { describe, it, expect, vi } from "vitest";

vi.mock("vike/server", () => ({
  renderPage: vi.fn(async () => ({ httpResponse: null })),
  createDevMiddleware: vi.fn(async () => ({ devMiddleware: () => {} }))
}));

import { app } from "../src/server/index";

describe("WebSocket", () => {
  it("should connect to /ws", async () => {
    // Listen on a random port
    app.listen(0);
    const port = app.server?.port;
    const wsUrl = `ws://localhost:${port}/ws`;
    
    const promise = new Promise<void>((resolve, reject) => {
      const ws = new WebSocket(wsUrl);
      
      const timeout = setTimeout(() => {
        ws.close();
        app.stop();
        reject(new Error("WebSocket connection timeout"));
      }, 5000);

      ws.onopen = () => {
        ws.send("ping");
      };

      ws.onmessage = (event) => {
        const msg = JSON.parse(event.data as string);
        if (msg.type === "pong") {
          clearTimeout(timeout);
          ws.close();
          app.stop();
          resolve();
        }
      };

      ws.onerror = (err) => {
        clearTimeout(timeout);
        app.stop();
        reject(err);
      };
    });

    await promise;
  });
});
