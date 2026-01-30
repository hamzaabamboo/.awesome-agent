import { Elysia } from "elysia";
import { staticPlugin } from "@elysiajs/static";
import { cors } from "@elysiajs/cors";
import { renderPage } from "vike/server";
import { getRalphStatus } from "./services/ralph";

const isProduction = process.env.NODE_ENV === "production";
const root = process.cwd();

const app = new Elysia()
  .use(cors())
  .use(staticPlugin({
    assets: "dist/client",
    prefix: "/"
  }))
  // API Routes
  .get("/api/health", () => ({ status: "ok" }))
  .get("/api/ralph/status", async () => await getRalphStatus())
  .get("/api/ralph/logs", async () => {
    try {
      return await Bun.file("ralph-runner.log").text();
    } catch {
      return "";
    }
  })
  .post("/api/ralph/logs/clear", async () => {
    await Bun.write("ralph-runner.log", "");
    return { success: true };
  })
  .post("/api/ralph/stop", async () => {
    const proc = Bun.spawn(["bash", "../agents/gemini/extensions/gemini-cli-ralph/scripts/cancel-ralph-loop.sh"]);
    await proc.exited;
    return { success: true };
  })
  .post("/api/ralph/start", async ({ body }: any) => {
    const { prompt, max_iterations, completion_promise, agent = "gemini" } = body;
    
    if (!["gemini", "claude"].includes(agent)) {
      return { success: false, error: "Invalid agent. Must be 'gemini' or 'claude'." };
    }

    Bun.spawn(["bash", "scripts/run-loop.sh", agent, prompt, String(max_iterations), completion_promise], {
      stdio: ["ignore", "inherit", "inherit"]
    });
    return { success: true };
  })
  // Vike SSR Middleware
  .all("*", async (context) => {
    const pageContextInit = {
      urlOriginal: context.request.url
    };
    const pageContext = await renderPage(pageContextInit);
    const { httpResponse } = pageContext;
    if (!httpResponse) return context.set.status = 404;
    
    const { body, statusCode, contentType } = httpResponse;
    context.set.status = statusCode;
    context.set.headers["content-type"] = contentType;
    return body;
  })
  .listen(3000);

console.log(`🦊 Ralph Commander (SSR) is running at http://localhost:3000`);
