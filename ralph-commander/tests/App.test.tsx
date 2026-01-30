import { describe, it, expect, mock } from "bun:test";
import { GlobalRegistrator } from "@happy-dom/global-registrator";

// Register globals
GlobalRegistrator.register();

import React from "react";
import { render } from "@testing-library/react";
import Page from "../src/pages/index/+Page";

describe("Index Page Component", () => {
  // Mock fetch
  const mockFetch = mock((url) => {
      if (url.toString().includes("/logs")) {
        return Promise.resolve({
            ok: true,
            text: () => Promise.resolve("Mock Logs\nLine 2")
        });
      }
      if (url.toString().includes("/tasks")) {
        return Promise.resolve({
            ok: true,
            json: () => Promise.resolve([])
        });
      }
      if (url.toString().includes("/files")) {
        return Promise.resolve({
            ok: true,
            json: () => Promise.resolve([])
        });
      }
      return Promise.resolve({
          ok: true,
          json: () => Promise.resolve({
              active: true,
              iteration: 1,
              max_iterations: 10,
              completion_promise: "TEST",
              started_at: new Date().toISOString(),
              prompt: "Test Prompt"
          })
      });
  });
  
  global.fetch = mockFetch as any;

  it("renders the header", async () => {
    const { findByText } = render(<Page />);
    
    // Check for "Ralph Commander" header
    const headerElement = await findByText(/Ralph Commander/i);
    expect(headerElement).toBeTruthy();
  });
});
