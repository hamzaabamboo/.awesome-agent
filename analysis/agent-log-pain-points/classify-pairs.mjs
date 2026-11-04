import { readFileSync } from "node:fs";

const blocks = readFileSync(process.argv[2], "utf8").split("\n### ");
const classes = {
  "asked question / offered options": /(\b(Should I|Shall I|May I|Want me to|Do you want|Would you like)\b[^.\n]*\?|\bWhich (one|option)[^.\n]*\?|\b(confirm|approve|Let me know|Reply with)\b[^.\n]*\?|\bsay (so|if you want)\b)/i,
  "reported blocked / waiting": /(blocked|blocker|cannot proceed|can.t proceed|waiting (for|on)|awaiting|needs? your|requires? (your|user|you)|on hold)/i,
  "cited disk space": /(disk|free space|GiB free|GB free|volume)/i,
  "cited rules/permission": /(AGENTS\.md|CLAUDE\.md|rule(s)? (prohibit|forbid|bar)|not (allowed|permitted|authorized)|without (your )?(explicit )?(approval|permission|authorization))/i,
  "listed remaining/unverified": /(remain(s|ing)? (open|unresolved|incomplete)|not (yet )?(verified|done|tested)|unverified|still (open|missing|pending)|next steps?:|left to do|incomplete)/i,
  "claimed done/verified": /(all (done|set|green)|\bis done|\bcomplete[d.]|(?<!un)(?<!not )(?<!not yet )\bverified|\bpasses|works now|\bfixed)/i,
  "gave path instead of showing": /(\/Users\/[^ ]+\.(png|html|mp4|pdf|jpg|webm)|open -R|! open)/i,
};
const agentText = (block) => (block.split("\nAGENT: ")[1] || "").split("\nTOOLS:")[0];
for (const [name, re] of Object.entries(classes)) {
  console.log(blocks.filter((block) => re.test(agentText(block))).length, "|", name);
}
console.log(blocks.length, "| pairs");
