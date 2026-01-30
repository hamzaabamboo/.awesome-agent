import { join } from 'path';
import { Elysia } from 'elysia';
import { staticPlugin } from '@elysiajs/static';
import { cors } from '@elysiajs/cors';
import { connect } from 'elysia-connect-middleware';
import { renderPage } from 'vike/server';
import { getRalphStatus } from './services/ralph';

// Configuration
const isProduction = process.env.NODE_ENV === 'production';
const root = process.cwd();

const app = new Elysia()
  .use(cors());

// Vike SSR Development Middleware
if (!isProduction) {
  const { createDevMiddleware } = await import('vike/server');
  const { devMiddleware } = await createDevMiddleware({ root });
  app.use(connect(devMiddleware));
} else {
  // Production: Serve static assets
  app.use(
    staticPlugin({
      assets: join(root, 'dist', 'client'),
      prefix: '/'
    })
  );
}

// API Routes
app
  .get("/api/health", () => ({ status: "ok" }))
  .get("/api/ralph/status", async () => await getRalphStatus())
  .get("/api/ralph/logs", async () => {
    try {
      const logPath = "ralph-runner.log";
      const file = Bun.file(logPath);
      if (await file.exists()) return await file.text();
      return "";
    } catch { return "Error reading logs."; }
  })
  .delete("/api/ralph/logs", async () => {
    try {
      await Bun.write("ralph-runner.log", "");
      return { success: true };
    } catch { return { success: false, error: "Failed to clear logs" }; }
  })
  .post("/api/ralph/stop", async () => {
    const proc = Bun.spawn(["bash", "../agents/gemini/extensions/gemini-cli-ralph/scripts/cancel-ralph-loop.sh"]);
    await proc.exited;
    return { success: true };
  })
  .post("/api/ralph/start", async ({ body }: any) => {
    const { prompt, max_iterations, completion_promise, agent = "gemini" } = body;
    if (!["gemini", "claude"].includes(agent)) return { success: false, error: "Invalid agent" };
    
    Bun.spawn(["bash", "scripts/run-loop.sh", agent, prompt, String(max_iterations), completion_promise], {
      stdio: ["ignore", "inherit", "inherit"]
    });
    return { success: true };
  });

// Catch-all route for SSR (must be last)
app.all('*', async (context) => {
  const pageContextInit = {
    urlOriginal: context.request.url,
    headers: Object.fromEntries(context.request.headers.entries())
  };
  
  const pageContext = await renderPage(pageContextInit);
  const { httpResponse } = pageContext;

  if (!httpResponse) {
    return context.set.status = 404;
  }

  const { body, statusCode, headers } = httpResponse;
  
  return new Response(body, {
    status: statusCode,
    headers: headers as HeadersInit
  });
});

app.listen({ port: 3000, hostname: '0.0.0.0' });
console.log(`🦊 Ralph Commander (SSR) is running at http://localhost:3000`);
