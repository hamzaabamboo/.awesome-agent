import { readFileSync } from "node:fs";

const seen = new Set();
const messages = [];
for (const line of readFileSync(process.argv[2], "utf8").split("\n")) {
  if (!line) continue;
  const message = JSON.parse(line);
  const text = message.text.replace(/\s+/g, " ").trim();
  if (text.length > 800 || text.startsWith("<")) continue;
  const key = text.slice(0, 200);
  if (seen.has(key)) continue;
  seen.add(key);
  messages.push({ ...message, text });
}

const buckets = {
  "idle/doing nothing/status ping": /nothing|idl|slacking|hello\s*\?|status|are you work|how (is|are) (work|we)|what are you doing/i,
  "declared done but not / wrap up means finish": /\bdone\b|100%|finish|lingering|remaining|wrap ?up/i,
  "didnt test / verify / check": /\btest|\bcheck|verif/i,
  "show me / open browser / finder / QR": /show me|\bopen\b|browser|finder|where is|\bqr\b|\burl\b|live page|vscode|preview/i,
  "asking instead of doing / permission": /do it|\bask|permission|block|approve|told you/i,
  "disk space excuse / self-block": /disk|space|mo clean|node.?modules|\bgb\b|brick/i,
  "repeat/ignored instruction": /what did i|told you|did i not|again\?|not this .*again|how many .*time|keep .*(ignoring|asking|doing)/i,
  "bad UI/slop/design": /trash|slop|looks? (like )?shit|ugly|bland|clutter|layout|\bui\b|\bux\b|design/i,
  "one-by-one instead of bulk/script/parallel": /one.by.one|bulk|batch|script|parallel|subagent|pro max|full force|max capacity|efficient/i,
  "git/pr/push/main/cleanup": /push|\bmain\b|merge|\bpr\b|working tree|worktree|commit|branch/i,
  "guessing / not reading source/refs": /guess|\bread\b|reference|source|hallucinat|assum/i,
  "copy format / daily report": /\bcopy|format|daily report|day report/i,
  "other session / tab coordination / naming": /other (tab|session)|\bname\b|nickname|which one of you|\btick\b/i,
  "spiraling / slow / token burn": /spiral|slow|so long|eternity|token|how much longer|too long/i,
};
const rows = Object.entries(buckets).map(([name, re]) => {
  const hits = messages.filter((message) => re.test(message.text));
  const projects = new Set(hits.map((message) => (message.cwd || "").split("/").slice(3, 5).join("/")));
  return [hits.length, name, projects.size];
});
for (const row of rows.sort((a, b) => b[0] - a[0])) console.log(row.join(" | "));
console.log(messages.length, "| messages");
