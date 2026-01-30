import react from "@vitejs/plugin-react";
import { defineConfig } from "vite";
import vike from "vike/plugin";
import path from "path";

export default defineConfig({
  plugins: [react(), vike()],
  resolve: {
    alias: {
      "~": path.resolve(__dirname, "src"),
    },
  },
  build: {
    outDir: "dist/client",
  },
  optimizeDeps: {
    exclude: ["playwright", "@playwright/test", "fsevents"],
  },
  ssr: {
    external: ["playwright", "@playwright/test", "fsevents"],
  },
  test: {
    globals: true,
    environment: "jsdom",
    setupFiles: ["./tests/setup.ts"],
    include: [
      "tests/App.test.tsx",
      "tests/components/**/*.test.tsx",
      "tests/store/**/*.test.ts"
    ],
  },
});
