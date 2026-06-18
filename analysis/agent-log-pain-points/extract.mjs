import { createReadStream, mkdirSync, readFileSync, readdirSync, statSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { createInterface } from "node:readline";

const home = "/Users/vittayapalotai.tanyawat";
const since = new Date("2026-03-17T15:00:00.000Z");
const until = new Date("2026-06-18T15:00:00.000Z");
const outDir = join(process.cwd(), "analysis/agent-log-pain-points/out");
const messagesPath = join(outDir, "messages.jsonl");
const reportPath = join(outDir, "summary.json");

mkdirSync(outDir, { recursive: true });

const messages = [];

function files(root, predicate) {
  const stack = [root];
  const found = [];
  while (stack.length) {
    const path = stack.pop();
    let stat;
    try {
      stat = statSync(path);
    } catch {
      continue;
    }
    if (stat.isDirectory()) {
      for (const entry of readdirSync(path)) stack.push(join(path, entry));
      continue;
    }
    if (predicate(path, stat)) found.push(path);
  }
  return found.sort();
}

function textFromCodexContent(content) {
  if (typeof content === "string") return content;
  if (!Array.isArray(content)) return "";
  return content
    .filter((item) => item?.type === "input_text")
    .map((item) => item.text || "")
    .join("\n\n")
    .trim();
}

function textFromClaudeContent(content) {
  if (typeof content === "string") return content;
  if (!Array.isArray(content)) return "";
  if (content.some((item) => item?.type === "tool_result" || item?.tool_use_id)) return "";
  return content
    .filter((item) => item?.type === "text")
    .map((item) => item.text || "")
    .join("\n\n")
    .trim();
}

function normalizeText(text) {
  if (!text) return "";
  const goal = text.match(/<command-name>\/goal<\/command-name>[\s\S]*?<command-args>([\s\S]*?)<\/command-args>/);
  if (goal) return goal[1].trim();
  const commandArgs = text.match(/<command-name>[^<]*<\/command-name>[\s\S]*?<command-args>([\s\S]*?)<\/command-args>/);
  if (commandArgs) return commandArgs[1].trim();
  if (text.includes("<command-message>") || text.includes("<command-name>")) return "";
  const goalContext = text.match(/<goal_context>[\s\S]*?<objective>\n?([\s\S]*?)\n?<\/objective>/);
  if (goalContext) return goalContext[1].trim();
  if (text === "[Request interrupted by user]" || text === "[Request interrupted by user for tool use]") return "";
  if (text.includes("<turn_aborted>")) return "";
  if (text.startsWith("This session is being continued from a previous conversation")) return "";
  if (text.startsWith("<skill>")) return "";
  if (text.startsWith("# Memory Index")) return "";
  if (text.includes("<local-command-stdout>") || text.includes("<local-command-caveat>")) return "";
  if (text.includes("<task-notification>") || text.includes("<subagent_notification>")) return "";
  if (text.includes("<bash-stdout>") || text.includes("<bash-input>") || text.includes("<bash-stderr>")) return "";
  if (text.startsWith("# AGENTS.md instructions")) return "";
  if (text.startsWith("<environment_context>")) return "";
  if (text.startsWith("# Context from my IDE setup:")) {
    const request = text.match(/## My request for (?:Codex|Claude):\n?([\s\S]*)/);
    return request ? normalizeText(request[1].trim()) : "";
  }
  if (
    text.startsWith("Workspace:") ||
    text.startsWith("Read-only ") ||
    text.startsWith("Review PR #") ||
    text.startsWith("Work in /Users/") ||
    /^You are (cross-checking|auditing|reviewing|fixing|investigating|checking)\b/.test(text)
  ) return "";
  if (text.startsWith("<codex_internal_context")) {
    const objective = text.match(/<objective>\n?([\s\S]*?)\n?<\/objective>/);
    return objective ? objective[1].trim() : "";
  }
  return text
    .replace(/<image\b[^>]*>[\s\S]*?<\/image>/g, "")
    .replace(/\[Image #\d+\]/g, "")
    .trim();
}

function addMessage(message) {
  const text = normalizeText(message.text);
  if (!text) return;
  if (text.length > 40000) return;
  messages.push({ ...message, text });
}

async function readJsonl(path, onRecord) {
  const rl = createInterface({ input: createReadStream(path), crlfDelay: Infinity });
  for await (const line of rl) {
    if (!line.trim()) continue;
    try {
      await onRecord(JSON.parse(line));
    } catch {}
  }
}

async function readCodex(path) {
  let cwd = "";
  let sessionId = "";
  await readJsonl(path, (record) => {
    if (record.type === "session_meta") {
      cwd = record.payload?.cwd || cwd;
      sessionId = record.payload?.id || sessionId;
      return;
    }
    if (record.type !== "response_item") return;
    const payload = record.payload;
    if (payload?.type !== "message" || payload.role !== "user") return;
    const timestamp = record.timestamp || "";
    if (timestamp) {
      const date = new Date(timestamp);
      if (date < since || date >= until) return;
    }
    addMessage({
      source: "codex",
      timestamp,
      cwd,
      sessionId,
      path,
      text: textFromCodexContent(payload.content)
    });
  });
}

async function readClaude(path) {
  await readJsonl(path, (record) => {
    if (record.type !== "user") return;
    if (record.isMeta && !String(record.message?.content || "").includes("<command-name>/goal</command-name>")) return;
    const timestamp = record.timestamp || "";
    if (timestamp) {
      const date = new Date(timestamp);
      if (date < since || date >= until) return;
    }
    addMessage({
      source: "claude",
      timestamp,
      cwd: record.cwd || "",
      sessionId: record.sessionId || "",
      path,
      text: textFromClaudeContent(record.message?.content)
    });
  });
}

function readMemory(path, source) {
  const stat = statSync(path);
  if (stat.mtime < since || stat.mtime >= until) return;
  const text = normalizeText(readFileSync(path, "utf8"));
  if (!text) return;
  addMessage({
    source,
    timestamp: stat.mtime.toISOString(),
    cwd: dirname(path),
    sessionId: "",
    path,
    text
  });
}

const stopwords = new Set("the a an and or to of in for on with this that it is are be as at by from i you me my we our your not do does did done have has had but so just into if then than can could should would will all there here about when what where how why still need needs make made use using work working fix fixed look checked check run ran get got".split(" "));

function words(text) {
  return text
    .toLowerCase()
    .replace(/https?:\/\/\S+/g, " ")
    .replace(/[`*_#<>{}()[\],.:;!?/\\|="'“”‘’]/g, " ")
    .split(/\s+/)
    .filter((word) => word.length > 2 && !stopwords.has(word) && !/^\d+$/.test(word));
}

function countBy(items, getKey) {
  const map = new Map();
  for (const item of items) {
    const key = getKey(item);
    map.set(key, (map.get(key) || 0) + 1);
  }
  return [...map.entries()].sort((a, b) => b[1] - a[1]);
}

function phraseCounts() {
  const phrases = [
    "read", "look", "verify", "browser", "screenshot", "screenshot", "evidence", "actual", "real", "logs",
    "do not", "don't", "stop", "ask", "wrong", "shit", "ffs", "deploy", "deploy-ready", "PR", "pr", "commit",
    "push", "merge", "copy", "paste", "memory", "goal", "resume", "continue", "audit", "all that shit",
    "why", "how", "fix", "test", "build", "lint", "typecheck", "auth", "local", "docker", "AWS", "browser"
  ];
  return phrases.map((phrase) => {
    const re = new RegExp(phrase.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"), "gi");
    const hits = messages.filter((message) => re.test(message.text));
    return { phrase, count: hits.length, examples: hits.slice(0, 8).map(sample) };
  }).filter((item) => item.count).sort((a, b) => b.count - a.count);
}

function sample(message) {
  return {
    timestamp: message.timestamp,
    source: message.source,
    cwd: message.cwd,
    path: message.path,
    text: message.text.replace(/\s+/g, " ").slice(0, 500)
  };
}

function buckets() {
  const defs = [
    ["verification_and_proof", /\b(verify|verification|evidence|proof|screenshot|video|browser|dogfood|actual|real|show|logs?)\b/i],
    ["agent_behavior", /\b(do not|don't|stop|ask|read|look|no fluff|comments|hallucinate|skim|wrong|instructions|memory|goal|continue|resume)\b/i],
    ["git_pr_delivery", /\b(pr|pull request|commit|push|merge|branch|deploy|deploy-ready|gh|github)\b/i],
    ["local_environment", /\b(local|docker|port|env|aws|bedrock|cognito|auth|login|database|db|dev server)\b/i],
    ["ui_quality", /\b(ui|ux|nav|design|screenshot|mobile|pixel|figma|visual|layout|button|modal|dialog|shit)\b/i],
    ["speed_and_autonomy", /\b(continue|finish|do it|all that|everything|don't ask|must|immediately|keep going)\b/i]
  ];
  return defs.map(([name, re]) => {
    const hits = messages.filter((message) => re.test(message.text));
    return { name, count: hits.length, examples: hits.slice(0, 20).map(sample) };
  }).sort((a, b) => b.count - a.count);
}

const codexFiles = files(join(home, ".codex/sessions/2026"), (path, stat) => path.endsWith(".jsonl") && stat.mtime >= since && stat.mtime < until);
const claudeFiles = files(join(home, ".claude/projects"), (path, stat) => path.endsWith(".jsonl") && !path.includes("/subagents/") && stat.mtime >= since && stat.mtime < until);
const claudeMemoryFiles = files(join(home, ".claude/projects"), (path, stat) => path.includes("/memory/") && path.endsWith(".md") && stat.mtime >= since && stat.mtime < until);
const codexMemoryFiles = files(join(home, ".codex/memories/extensions/ad_hoc/notes"), (path, stat) => path.endsWith(".md") && stat.mtime >= since && stat.mtime < until);

for (const path of codexFiles) await readCodex(path);
for (const path of claudeFiles) await readClaude(path);
for (const path of claudeMemoryFiles) readMemory(path, "claude-memory");
for (const path of codexMemoryFiles) readMemory(path, "codex-memory");

messages.sort((a, b) => String(a.timestamp).localeCompare(String(b.timestamp)));

const allWords = new Map();
for (const message of messages) {
  for (const word of words(message.text)) allWords.set(word, (allWords.get(word) || 0) + 1);
}

writeFileSync(messagesPath, messages.map((message) => JSON.stringify(message)).join("\n") + "\n");
writeFileSync(reportPath, JSON.stringify({
  since: since.toISOString(),
  until: until.toISOString(),
  codexFiles: codexFiles.length,
  claudeFiles: claudeFiles.length,
  claudeMemoryFiles: claudeMemoryFiles.length,
  codexMemoryFiles: codexMemoryFiles.length,
  messages: messages.length,
  uniqueTexts: new Set(messages.map((message) => message.text.replace(/\s+/g, " ").trim())).size,
  bySource: countBy(messages, (message) => message.source),
  byCwd: countBy(messages, (message) => message.cwd || "(unknown)").slice(0, 40),
  topWords: [...allWords.entries()].sort((a, b) => b[1] - a[1]).slice(0, 120),
  phraseCounts: phraseCounts(),
  buckets: buckets()
}, null, 2));

console.log(reportPath);
