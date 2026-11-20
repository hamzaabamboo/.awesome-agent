import { createReadStream, statSync } from "node:fs";
import { createInterface } from "node:readline";
import { spawn } from "node:child_process";

const design = /\b(design|ui|ux|layout|visual|typography|font|spacing|palette|mockup|figma|redesign|screen|animation|motion|dashboard|landing page|colou?r|cent(?:er|re)(?:ing)?|alignment|chip|contrast|padding|overflow|responsive)\b/i;
const rejection = /\b(trash|ugly|generic|slop|wrong|bad|shit|terrible|awful|hate|boring|broken|reject|worse|stop|nope|ffs|fuck|not what|doesn't match|does not match)\b/i;
const excluded = /(?:^|[/\\])(?:subagents?|memory|memories|tool-results?)(?:[/\\]|$)/i;

export function normalizeText(value) {
  if (typeof value !== "string") return "";
  let text = value.replace(/<(system-reminder|recommended_plugins|environment_context|skills_instructions)\b[^>]*>[\s\S]*?<\/\1>/gi, "").trim();
  text = text.replace(/<image\b[^>]*>[\s\S]*?<\/image>/gi, "").replace(/^Codex could not read the local image[^\n]*(?:\n|$)/gm, "").trim();
  if (text.startsWith("You are in a side chat beside the main thread")) {
    const human = text.match(/\nUser message:\s*([\s\S]*)$/);
    return human ? normalizeText(human[1]) : "";
  }
  const goal = text.match(/<command-name>\s*\/goal\s*<\/command-name>[\s\S]*?<command-args>([\s\S]*?)<\/command-args>/i);
  if (goal) return goal[1].trim();
  if (/^\s*(?:This session is being continued from a previous conversation|# AGENTS\.md instructions|# Memory Index|<skill>|<environment_context>|<codex_internal_context|<goal_context>)/i.test(text)) return "";
  if (/^\s*(?:You are in a side chat beside the main thread|You are an independent third-party reviewer|You are (?:cross-checking|auditing|reviewing|fixing|investigating|checking)\b|Stop hook feedback:|Stop-hook feedback:|\[Request interrupted by user)/i.test(text)) return "";
  text = text.replace(/<(task-notification|subagent_notification|local-command-stdout|local-command-caveat|user_shell_command|bash-stdout|bash-input|bash-stderr|turn_aborted)\b[^>]*>[\s\S]*?<\/\1>/gi, "");
  if (/<command-(?:name|message)>/i.test(text)) return "";
  if (text.startsWith("# Context from my IDE setup:")) {
    text = text.match(/## My request for (?:Codex|Claude):\s*([\s\S]*)/)?.[1] || "";
  }
  return text.trim();
}

export function extractMessage(record, source) {
  const payload = source === "codex" ? record.type === "response_item" ? record.payload : null : record.message;
  const role = source === "codex" ? payload?.role : record.type;
  if (!["user", "assistant"].includes(role) || !payload || (source === "codex" && payload.type !== "message")) return null;
  if (record.isSidechain || record.isSubagent || record.agentId) return null;
  if (role === "assistant" && payload.channel && !["final", "commentary"].includes(payload.channel)) return null;
  const content = payload.content;
  const raw = typeof content === "string" ? content : Array.isArray(content) ? content.filter((item) => ["text", "input_text", "output_text"].includes(item?.type)).map((item) => item.text || "").join("\n\n") : "";
  if ((record.isMeta || payload.isMeta) && !/<command-name>\s*\/goal\s*<\/command-name>/i.test(raw)) return null;
  const text = normalizeText(raw);
  return text ? { role, channel: payload.channel || null, text, timestamp: record.timestamp || payload.timestamp || "", id: record.uuid || payload.id || record.id || "" } : null;
}

export async function readCodexSessionMetadata(path, maxBytes = 65536) {
  if (!/\.jsonl(?:\.zst)?$/.test(path) || !Number.isSafeInteger(maxBytes) || maxBytes < 1) throw new Error("Explicit JSONL path and positive metadata byte limit required");
  const child = path.endsWith(".zst") ? spawn("zstd", ["-dcq", path], { stdio: ["ignore", "pipe", "pipe"] }) : null;
  let failure;
  const completion = child ? new Promise((resolve) => {
    child.once("error", (error) => { failure = error; resolve(); });
    child.once("close", () => resolve());
    child.stderr.resume();
  }) : null;
  const input = child?.stdout || createReadStream(path, { highWaterMark: Math.min(4096, maxBytes) });
  let bytes = Buffer.alloc(0);
  try {
    for await (const chunk of input) {
      const newline = chunk.indexOf(10);
      const first = newline < 0 ? chunk : chunk.subarray(0, newline);
      if (bytes.length + first.length > maxBytes) throw new Error("Session metadata exceeds byte limit");
      bytes = Buffer.concat([bytes, first]);
      if (newline >= 0) break;
    }
    if (failure) throw failure;
    const record = JSON.parse(bytes.toString("utf8"));
    if (record.type !== "session_meta" || typeof record.payload?.cwd !== "string") throw new Error("First record is not Codex session metadata");
    return { cwd: record.payload.cwd, source: record.payload.source };
  } finally {
    input.destroy();
    if (child && child.exitCode === null) child.kill();
    if (completion) await completion;
  }
}

async function* lines(file) {
  if (file.size === 0 && !file.path.endsWith(".zst")) return;
  let child;
  let input;
  let failure;
  let completion;
  if (file.path.endsWith(".zst")) {
    child = spawn("zstd", ["-dcq", file.path], { stdio: ["ignore", "pipe", "pipe"] });
    child.stderr.resume();
    completion = new Promise((resolve) => {
      child.once("error", (error) => { failure = error; resolve(); });
      child.once("close", (code) => { if (code !== 0) failure ||= new Error("decompression failed"); resolve(); });
    });
    input = child.stdout;
  } else input = createReadStream(file.path, file.size ? { end: file.size - 1 } : undefined);
  const reader = createInterface({ input, crlfDelay: Infinity });
  try {
    for await (const line of reader) yield line;
    if (completion) await completion;
    if (failure) throw failure;
  } finally {
    reader.close();
    input.destroy();
    if (child && child.exitCode === null) child.kill();
  }
}

export function createDesignIndex({ files, since, until, projectRoots = [] }) {
  const start = Date.parse(since);
  const end = Date.parse(until);
  if (!Array.isArray(files) || !Number.isFinite(start) || !Number.isFinite(end) || start >= end) throw new Error("Explicit files and valid since/until bounds required");
  if (!Array.isArray(projectRoots)) throw new Error("Explicit Codex project roots required");
  const roots = projectRoots.map((root) => typeof root === "string" ? root.replace(/\/+$/, "") : "");
  if (files.some((file) => file?.source === "codex") && (!roots.length || roots.some((root) => !root.startsWith("/") || root.length < 2))) throw new Error("Explicit Codex project roots required");
  const index = {
    episodes: [],
    issues: [],
    fileMap: new Map(),
    coverage: { filesTotal: files.length, filesRead: 0, filesExcluded: 0, linesRead: 0, malformed: 0, missingTime: 0, outsideBounds: 0, duplicates: 0, messages: 0, episodes: 0, gaps: 0, changedFiles: 0, done: 0 },
    getEpisodes(offset = 0, limit = 20) { return this.episodes.slice(offset, offset + limit); }
  };
  let position = 0;
  let current;
  function finish(reason) {
    if (current?.episode) current.episode.closure = reason;
    if (current) {
      try {
        const after = statSync(current.file.path);
        if (current.before.size !== after.size || current.before.mtimeMs !== after.mtimeMs) index.coverage.changedFiles++;
      } catch { index.coverage.gaps++; }
      if (reason !== "excluded") index.fileMap.set(current.file.path, current.messages.map(({ role, timestamp, source, humanOrdinal }) => ({ role, timestamp, source, humanOrdinal })));
    }
    current = null;
  }
  index.close = async () => {
    if (current) await current.iterator.return();
    finish("cancelled");
    index.coverage.closed = 1;
  };
  index.step = async (budgetMs = 100) => {
    if (index.coverage.closed) throw new Error("Index is closed");
    const deadline = performance.now() + Math.max(1, budgetMs);
    do {
      if (!current) {
        if (position >= files.length) { index.coverage.done = 1; break; }
        const file = files[position++];
        if (!file || !["codex", "claude"].includes(file.source) || excluded.test(file.path) || !/\.jsonl(?:\.zst)?$/.test(file.path)) { index.coverage.filesExcluded++; continue; }
        let before;
        try { before = statSync(file.path); } catch { index.coverage.gaps++; continue; }
        let project = file.project || "";
        if (file.source === "codex") {
          let metadata;
          try { metadata = await readCodexSessionMetadata(file.path); } catch { index.coverage.gaps++; index.issues.push({ path: file.path, line: 1, kind: "metadata-error" }); continue; }
          if (metadata.source?.subagent || metadata.source === "subagent" || !roots.some((root) => metadata.cwd === root || metadata.cwd.startsWith(`${root}/`))) { index.coverage.filesExcluded++; continue; }
          project = metadata.cwd;
        }
        current = { file, before, project, iterator: lines({ ...file, size: before.size }), line: 0, messages: [], seen: new Set(), ordinal: 0, topic: -1, goal: null, episode: null };
        index.fileMap.set(file.path, current.messages);
      }
      let result;
      try { result = await current.iterator.next(); } catch { index.coverage.gaps++; index.issues.push({ path: current.file.path, line: current.line, kind: "read-error" }); finish("read-error"); continue; }
      if (result.done) { index.coverage.filesRead++; finish("end-of-file"); continue; }
      current.line++;
      index.coverage.linesRead++;
      if (!result.value.trim()) continue;
      let record;
      try { record = JSON.parse(result.value); } catch { index.coverage.malformed++; index.issues.push({ path: current.file.path, line: current.line, kind: "malformed" }); continue; }
      if (record.type === "session_meta" && (record.payload?.source?.subagent || record.payload?.source === "subagent")) {
        await current.iterator.return();
        index.coverage.filesExcluded++;
        index.coverage.messages -= current.messages.length;
        index.episodes = index.episodes.filter((episode) => episode.source.path !== current.file.path);
        index.coverage.episodes = index.episodes.length;
        index.fileMap.delete(current.file.path);
        finish("excluded");
        continue;
      }
      current.project = record.payload?.cwd || record.cwd || current.project;
      const message = extractMessage(record, current.file.source);
      if (!message) continue;
      const time = Date.parse(message.timestamp);
      if (!Number.isFinite(time)) { index.coverage.missingTime++; continue; }
      if (time < start || time >= end) { index.coverage.outsideBounds++; continue; }
      const key = message.id ? `${message.role}:${message.id}` : `${message.role}:${message.timestamp}:${message.text}`;
      if (current.seen.has(key)) { index.coverage.duplicates++; continue; }
      current.seen.add(key);
      const locator = { path: current.file.path, line: current.line, source: current.file.source };
      const item = { ...message, source: locator, humanOrdinal: message.role === "user" ? ++current.ordinal : null };
      const offset = current.messages.length;
      const isRejection = message.role === "user" && rejection.test(message.text.replace(/\$[\w:-]+/g, "").replace(/\banti[- ]slop\b/gi, "")) && (design.test(message.text) || (current.topic >= 0 && current.ordinal - current.messages[current.topic].humanOrdinal <= 3));
      if (message.role === "user") {
        current.goal ||= item;
        if (current.episode && !isRejection) { current.episode.closure = "next-human-boundary"; current.episode = null; }
        if (isRejection && !current.episode) {
          current.episode = { project: current.project, source: locator, firstInWindowHuman: current.goal, nearestDesignRequest: current.topic < 0 ? null : current.messages[current.topic], candidateOrdinals: [], responses: [], context: current.messages.slice(current.topic < 0 ? 0 : current.topic), closure: "open", completion: "not-established" };
          index.episodes.push(current.episode);
          index.coverage.episodes++;
        }
        if (isRejection) current.episode.candidateOrdinals.push(current.ordinal);
        if (design.test(message.text) && !isRejection) current.topic = offset;
      }
      current.messages.push(item);
      if (current.episode) current.episode.context.push(item);
      if (current.episode && item.role === "assistant") current.episode.responses.push(item);
      index.coverage.messages++;
    } while (performance.now() < deadline);
    return { ...index.coverage };
  };
  return index;
}
