import { describe, it, expect, mock } from "bun:test";
import { GlobalRegistrator } from "@happy-dom/global-registrator";

// Register globals
GlobalRegistrator.register();

import React from "react";
import { render } from "@testing-library/react";
import App from "../src/client/App";

describe("App Component", () => {
  // Mock fetch
  const mockFetch = mock((url) => {
      if (url.toString().includes("/logs")) {
        return Promise.resolve({
            text: () => Promise.resolve("Mock Logs\nLine 2")
        });
      }
      return Promise.resolve({
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
    // Debug
    // console.log("Document defined?", typeof document !== 'undefined');
    
    const { findByText } = render(<App />);
    
    // We expect the "Loading" state initially because useEffect is async
    const loadingElement = await findByText(/Loading Ralph Status/i);
    expect(loadingElement).toBeTruthy();
  });
});
