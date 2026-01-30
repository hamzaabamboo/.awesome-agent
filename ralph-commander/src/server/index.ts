import { Elysia } from "elysia";
import { staticPlugin } from "@elysiajs/static";
import { cors } from "@elysiajs/cors";
import { renderPage } from "vike/server";
import { getRalphStatus } from "./services/ralph";

const isProduction = process.env.NODE_ENV === "production";
const root = process.cwd();

async function startServer() {
  const app = new Elysia();
  
  app.use(cors());

  // Global Error Handler
  app.onError(({ code, error, set }) => {
    console.error(`[Server Error] ${code}:`, error);
    set.status = 500;
    return {
      success: false,
      error: error.message || "Internal Server Error",
      code: code
    };
  });

  let vite: any;
  if (!isProduction) {
    const viteMod = await import("vite");
    vite = await viteMod.createServer({
      root,
      server: { middlewareMode: true },
      appType: 'custom'
    });
  } else {
    app.use(staticPlugin({
      assets: "dist/client",
      prefix: "/"
    }));
  }

  // API Routes
  app.get("/api/health", () => ({ status: "ok" }));
  
  app.get("/api/ralph/status", async () => {
    return await getRalphStatus();
  });

  app.get("/api/ralph/logs", async () => {
    try {
      const logPath = "ralph-runner.log";
      const file = Bun.file(logPath);
      if (await file.exists()) return await file.text();
      return "";
    } catch (err) { 
      console.error("Error reading logs:", err);
      return "Error reading logs."; 
    }
  });
  
  app.post("/api/ralph/stop", async () => {
    try {
      const proc = Bun.spawn(["bash", "../agents/gemini/extensions/gemini-cli-ralph/scripts/cancel-ralph-loop.sh"]);
      await proc.exited;
      if (proc.exitCode !== 0) {
        throw new Error(`Stop script exited with code ${proc.exitCode}`);
      }
      return { success: true };
    } catch (e) {
      throw new Error(`Failed to stop loop: ${(e as Error).message}`);
    }
  });
  
  app.post("/api/ralph/start", async ({ body }: any) => {
    const { prompt, max_iterations, completion_promise, agent = "gemini" } = body;
    if (!prompt) throw new Error("Prompt is required");
    if (!["gemini", "claude"].includes(agent)) throw new Error("Invalid agent");
    
    try {
      Bun.spawn(["bash", "scripts/run-loop.sh", agent, prompt, String(max_iterations), completion_promise], {
        stdio: ["ignore", "inherit", "inherit"]
      });
      return { success: true };
    } catch (e) {
      throw new Error(`Failed to start loop: ${(e as Error).message}`);
    }
  });

  // Vike/Vite Handler
  app.all("*", async (context) => {
    // 1. Try to let Vite handle the request (for assets, HMR, etc.) in Dev
    if (!isProduction && vite) {
      const handled = await new Promise<boolean>((resolve) => {
        // Create a mock req/res for Vite's Connect middleware
        const req: any = {
           url: context.request.url.replace(new URL(context.request.url).origin, ''),
           method: context.request.method,
           headers: context.request.headers.toJSON ? context.request.headers.toJSON() : Object.fromEntries(context.request.headers.entries()),
        };
        const res: any = {
           statusCode: 200,
           setHeader: (k: string, v: string) => { 
             if (!context.set.headers) context.set.headers = {};
             context.set.headers[k] = v;
           },
           end: () => resolve(true), // Vite handled it
           write: () => {}, 
           // If vite calls next(), we resolve false
        };
        
        vite.middlewares(req, res, () => resolve(false));
      });
      
      // If Vite handled it (like an asset), we stop here.
      // NOTE: This is tricky with Elysia because we need to return the body.
      // Vite writes to `res`. We captured the headers but not the body.
      // A proper adapter is non-trivial.
      
      // FALLBACK: For now, we rely on Vike's renderPage for HTML,
      // and we might miss Vite assets if not careful.
      // However, typical Vike setup just uses `renderPage` and lets `vite` handle the rest via a separate middleware.
    }
    
    // 2. Vike SSR
    const pageContextInit = {
      urlOriginal: context.request.url
    };
    
    const pageContext = await renderPage(pageContextInit);
    const { httpResponse } = pageContext;
    
    if (!httpResponse) {
        return context.set.status = 404;
    }
    
    const { body, statusCode, contentType } = httpResponse;
    context.set.status = statusCode;
    context.set.headers["content-type"] = contentType;
    return body;
  });

  app.listen(3000);
  console.log(`🦊 Ralph Commander (SSR) is running at http://localhost:3000`);
}

startServer();