import { createReadStream, readdirSync, statSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import { createInterface } from "node:readline";
import { spawn } from "node:child_process";
const home="/Users/vittayapalotai.tanyawat", since=new Date(process.env.SINCE), until=new Date(process.env.UNTIL);
if(!process.env.SINCE||!process.env.UNTIL) throw new Error("Set SINCE and UNTIL (ISO timestamps).");
const inWindow=(ts)=>{const d=new Date(ts);return !isNaN(d)&&d>=since&&d<until};
const angry=/(FUCK|SHIT|JESUS|FFS|ZZZ|\?\?\?|WHAT DID I|DID YOU|WHY ARE YOU|WHY THE|SKILL ISSUE|HELLO|BITCH)/;
function walk(r,pred,o=[]){for(const e of readdirSync(r)){const p=join(r,e);const s=statSync(p);if(s.isDirectory())walk(p,pred,o);else if(pred(p,s))o.push(p)}return o}
const out=[];
async function scan(path,kind){
  const input=path.endsWith(".zst")?spawn("zstd",["-dcq",path]).stdout:createReadStream(path);
  const rl=createInterface({input,crlfDelay:Infinity});let last="",tools=[],cwd="";
  for await(const line of rl){let r;try{r=JSON.parse(line)}catch{continue}
    if(kind==="codex"){if(r.type==="session_meta"){cwd=r.payload?.cwd||"";continue}
      const p=r.payload;if(r.type!=="response_item")continue;
      if(p?.type==="function_call"||p?.type==="custom_tool_call"){tools.push(String(p.arguments||p.input||"").slice(0,120));continue}
      if(p?.type!=="message")continue;
      const t=(p.content||[]).map(c=>c.text||"").join(" ").replace(/\s+/g," ").trim();
      if(p.role==="assistant"){if(t){last=t;}continue}
      if(p.role==="user"&&t.length<600&&angry.test(t)&&last&&!t.startsWith("<")&&inWindow(r.timestamp)){out.push({ts:r.timestamp,cwd,user:t,agent:last.slice(-700),tools:tools.slice(-4)});}
      if(p.role==="user"){tools=[]}
    } else {cwd=r.cwd||cwd;
      if(r.type==="assistant"){for(const c of r.message?.content||[]){if(c.type==="text"&&c.text.trim())last=c.text.replace(/\s+/g," ");if(c.type==="tool_use")tools.push(JSON.stringify(c.input).slice(0,120))}continue}
      if(r.type==="user"){const c=r.message?.content;const t=typeof c==="string"?c:(Array.isArray(c)&&!c.some(x=>x.type==="tool_result")?c.filter(x=>x.type==="text").map(x=>x.text).join(" "):"");
        if(!t)continue;const tt=t.replace(/\s+/g," ").trim();
        if(tt.length<600&&angry.test(tt)&&last&&!tt.startsWith("<")&&inWindow(r.timestamp)) out.push({ts:r.timestamp,cwd,user:tt,agent:last.slice(-700),tools:tools.slice(-4)});tools=[]}}
  }}
for(const p of walk(join(home,".codex/sessions"),(p,s)=>/\.jsonl(\.zst)?$/.test(p)&&s.mtime>=since))await scan(p,"codex");
for(const p of walk(join(home,".claude/projects"),(p,s)=>p.endsWith(".jsonl")&&!p.includes("/subagents/")&&s.mtime>=since))await scan(p,"claude");
const seen=new Set();const u=out.filter(o=>{const k=o.user.slice(0,200);if(seen.has(k))return false;seen.add(k);return true}).sort((a,b)=>String(a.ts).localeCompare(b.ts));
writeFileSync(process.argv[2],u.map(o=>`### ${String(o.ts).slice(0,16)} ${o.cwd.replace(home+"/","")}\nUSER: ${o.user}\nAGENT: ${o.agent}\nTOOLS: ${o.tools.join(" | ")}\n`).join("\n"));
console.log(u.length);
