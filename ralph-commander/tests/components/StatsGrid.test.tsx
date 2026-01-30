import { render, screen } from "@testing-library/react";
import { describe, it, expect, vi, beforeEach } from "vitest";
import { StatsGrid } from "../../src/pages/index/components/StatsGrid";
import { useRalphStore } from "../../src/renderer/store/useRalphStore";
import React from "react";

// Mock useRalphStore
vi.mock("../../src/renderer/store/useRalphStore", () => ({
  useRalphStore: vi.fn(),
}));

describe("StatsGrid Component", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("renders null when status is not provided", () => {
    (useRalphStore as any).mockImplementation((selector: any) => selector({ status: null }));
    const { container } = render(<StatsGrid />);
    expect(container.firstChild).toBeNull();
  });

  it("renders status data correctly", () => {
    const mockStatus = {
      active: true,
      iteration: 5,
      max_iterations: 10,
      started_at: new Date().toISOString(),
      agent: "gemini",
      model: "flash",
      stats: {
        total_duration_ms: 5000,
        avg_iteration_ms: 1000,
        iteration_history: [],
      },
    };

    (useRalphStore as any).mockImplementation((selector: any) => 
      selector({ 
        status: mockStatus,
        tasks: [{ completed: true }, { completed: false }]
      })
    );

    // Mock getState for the progress bar calculation which uses useRalphStore.getState()
    (useRalphStore as any).getState = () => ({
      tasks: [{ completed: true }, { completed: false }]
    });

    render(<StatsGrid />);

    expect(screen.getByText("5")).toBeDefined();
    expect(screen.getByText("/ 10")).toBeDefined();
    expect(screen.getByText("50%")).toBeDefined();
    expect(screen.getByText("gemini")).toBeDefined();
    expect(screen.getByText("flash")).toBeDefined();
  });
});
