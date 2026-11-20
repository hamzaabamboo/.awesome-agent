import test from "node:test";
import assert from "node:assert/strict";
import { mkdtemp, writeFile, rm } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { spawnSync } from "node:child_process";
import { createDesignIndex, extractMessage, normalizeText, readCodexSessionMetadata } from "../analysis/agent-log-pain-points/design-episodes.mjs";

const since = "2026-08-11T00:00:00Z";
const until = "2026-11-12T00:00:00Z";
const timestamp = "2026-09-01T00:00:00Z";
const message = (role, text, extra = {}) => ({ type: role, timestamp, message: { content: [{ type: "text", text }] }, ...extra });

test("normalization preserves human text and excludes generated metadata", () => {
  assert.equal(normalizeText("bad layout<system-reminder>generated</system-reminder> fix spacing"), "bad layout fix spacing");
  assert.equal(extractMessage(message("user", "bad design", { isMeta: true }), "claude"), null);
  assert.equal(extractMessage(message("user", "Stop hook feedback: bad design"), "claude"), null);
  assert.equal(extractMessage(message("user", "<task-notification>bad design</task-notification>"), "claude"), null);
  assert.equal(extractMessage(message("user", "<command-name>/goal</command-name><command-args>design homepage</command-args>", { isMeta: true }), "claude").text, "design homepage");
  assert.equal(extractMessage({ type: "user", timestamp, message: { content: [{ type: "tool_result", content: "bad design" }, { type: "text", text: "real human" }] } }, "claude").text, "real human");
  assert.equal(normalizeText("Wrong color and off-center labels"), "Wrong color and off-center labels");
  assert.equal(extractMessage({ type: "response_item", timestamp, payload: { type: "message", role: "assistant", content: [{ type: "output_text", text: "rendered design" }] } }, "codex").text, "rendered design");
});

test("bounded index preserves locators, groups corrections, and closes only at human boundary", async () => {
  const root = await mkdtemp(join(tmpdir(), "design-episodes-"));
  try {
    const path = join(root, "history.jsonl");
    const records = [message("user", "Design homepage"), message("assistant", "old completion"), message("user", "trash", { uuid: "a" }), message("user", "trash", { uuid: "a" }), message("user", "wrong spacing"), message("assistant", "new response"), message("user", "ship it"), message("user", "Wrong color and off-center labels"), message("assistant", "inspect affected controls"), message("user", "bad design", { timestamp: "2026-08-10T00:00:00Z" }), message("user", "bad design", { timestamp: "" })];
    await writeFile(path, records.map(JSON.stringify).join("\n") + "\n\ninvalid\n");
    const index = createDesignIndex({ files: [{ path, source: "claude" }, { path: join(root, "memory", "x.jsonl"), source: "claude" }], since, until });
    let coverage;
    do { coverage = await index.step(1); } while (!coverage.done);
    assert.equal(coverage.duplicates, 1);
    assert.equal(coverage.outsideBounds, 1);
    assert.equal(coverage.missingTime, 1);
    assert.equal(coverage.malformed, 1);
    assert.equal(coverage.filesExcluded, 1);
    assert.equal(index.episodes.length, 2);
    const episode = index.getEpisodes(0, 1)[0];
    assert.deepEqual(episode.candidateOrdinals, [2, 3]);
    assert.equal(episode.context.at(-1).text, "new response");
    assert.deepEqual(episode.responses.map((item) => item.text), ["new response"]);
    assert.equal(episode.source.line, 3);
    assert.equal(episode.closure, "next-human-boundary");
    assert.equal(episode.completion, "not-established");
    assert.equal(episode.nearestDesignRequest.text, "Design homepage");
    assert.equal(index.fileMap.get(path).length, 8);
    assert.equal(index.episodes[1].responses[0].text, "inspect affected controls");
    assert.equal(index.fileMap.get(path)[0].text, undefined);
  } finally { await rm(root, { recursive: true, force: true }); }
});

test("subagent origin and failed compressed input become exclusions and coverage gaps", async () => {
  const root = await mkdtemp(join(tmpdir(), "design-episodes-"));
  try {
    const path = join(root, "agent.jsonl");
    const compressed = join(root, "broken.jsonl.zst");
    await writeFile(path, JSON.stringify({ type: "session_meta", payload: { cwd: "/scoped/project", source: { subagent: {} } } }));
    await writeFile(compressed, "invalid compressed bytes");
    const index = createDesignIndex({ files: [{ path, source: "codex" }, { path: compressed, source: "codex" }], since, until, projectRoots: ["/scoped/project"] });
    let coverage;
    do { coverage = await index.step(10); } while (!coverage.done);
    assert.equal(coverage.filesExcluded, 1);
    assert.equal(coverage.gaps, 1);
    assert.equal(index.episodes.length, 0);
  } finally { await rm(root, { recursive: true, force: true }); }
});

test("closing a partial index releases its input and prevents an implicit restart", async () => {
  const root = await mkdtemp(join(tmpdir(), "design-episodes-"));
  try {
    const path = join(root, "partial.jsonl");
    await writeFile(path, [message("user", "Review chip colors"), message("user", "Wrong colors"), ...Array.from({ length: 10000 }, (_, i) => message("assistant", `Progress ${i}`))].map(JSON.stringify).join("\n"));
    const index = createDesignIndex({ files: [{ path, source: "claude" }], since, until });
    await index.step(1);
    assert.equal(index.coverage.filesRead, 0);
    await index.close();
    assert.equal(index.coverage.closed, 1);
    assert.equal(index.coverage.done, 0);
    await assert.rejects(index.step(), /Index is closed/);
  } finally { await rm(root, { recursive: true, force: true }); }
});

test("private assistant channels are not visible responses", () => {
  const record = { type: "response_item", timestamp, payload: { type: "message", role: "assistant", channel: "analysis", content: [{ type: "output_text", text: "internal analysis" }] } };
  assert.equal(extractMessage(record, "codex"), null);
  record.payload.channel = "final";
  assert.equal(extractMessage(record, "codex").channel, "final");
});

test("nearest design request is not misattributed to earlier unrelated work", async () => {
  const root = await mkdtemp(join(tmpdir(), "design-episodes-"));
  try {
    const path = join(root, "topics.jsonl");
    await writeFile(path, [message("user", "Fix database timeout"), message("assistant", "Database fixed"), message("user", "Design homepage"), message("user", "wrong layout"), message("assistant", "Inspect homepage")].map(JSON.stringify).join("\n"));
    const index = createDesignIndex({ files: [{ path, source: "claude" }], since, until });
    while (!(await index.step(10)).done) {}
    assert.equal(index.episodes[0].firstInWindowHuman.text, "Fix database timeout");
    assert.equal(index.episodes[0].nearestDesignRequest.text, "Design homepage");
  } finally { await rm(root, { recursive: true, force: true }); }
});

test("injected plugin prefixes and shell output are not human rejections", () => {
  assert.equal(normalizeText("<recommended_plugins>plugin list</recommended_plugins>\n# AGENTS.md instructions\nDesign rules with rejection words"), "");
  assert.equal(normalizeText("<user_shell_command><command>status</command><result>bad design</result></user_shell_command>"), "");
  assert.equal(normalizeText("<recommended_plugins>plugin list</recommended_plugins>\nPlease fix the layout"), "Please fix the layout");
  assert.equal(normalizeText("<image name=sample>metadata</image>\nYou are an independent third-party reviewer of a design"), "");
  assert.equal(normalizeText("You are in a side chat beside the main thread. Historical activity follows."), "");
  assert.equal(normalizeText("You are in a side chat beside the main thread.\nOld activity: UI was wrong\nUser message:\nFix label centering"), "Fix label centering");
});

test("metadata selection reads only the bounded first record", async () => {
  const root = await mkdtemp(join(tmpdir(), "design-episodes-"));
  try {
    const path = join(root, "metadata.jsonl");
    await writeFile(path, JSON.stringify({ type: "session_meta", payload: { cwd: "/scoped/project", source: "cli", id: "private" } }) + "\n" + "unparsed private body".repeat(1000));
    assert.deepEqual(await readCodexSessionMetadata(path), { cwd: "/scoped/project", source: "cli" });
    const compressed = join(root, "metadata.jsonl.zst");
    const result = spawnSync("zstd", ["-cq"], { input: JSON.stringify({ type: "session_meta", payload: { cwd: "/scoped/project", source: "cli" } }) + "\n" + "unparsed private body".repeat(1000) });
    assert.equal(result.status, 0);
    await writeFile(compressed, result.stdout);
    assert.deepEqual(await readCodexSessionMetadata(compressed), { cwd: "/scoped/project", source: "cli" });
    await assert.rejects(readCodexSessionMetadata(compressed, 10), /byte limit/);
    await assert.rejects(readCodexSessionMetadata(path, 10), /byte limit/);
    await writeFile(path, JSON.stringify(message("user", "unscoped body")));
    await assert.rejects(readCodexSessionMetadata(path), /not Codex session metadata/);
  } finally { await rm(root, { recursive: true, force: true }); }
});

test("Codex indexing requires scoped metadata before opening message content", async () => {
  const root = await mkdtemp(join(tmpdir(), "design-episodes-"));
  try {
    const path = join(root, "unselected.jsonl");
    await writeFile(path, JSON.stringify({ type: "session_meta", payload: { cwd: "/scoped/project-other", source: "cli" } }) + "\ninvalid unselected body");
    const files = [{ path, source: "codex" }];
    assert.throws(() => createDesignIndex({ files, since, until }), /project roots/);
    assert.throws(() => createDesignIndex({ files, since, until, projectRoots: ["///"] }), /project roots/);
    assert.throws(() => createDesignIndex({ files, since, until, projectRoots: "/scoped/project" }), /project roots/);
    const index = createDesignIndex({ files, since, until, projectRoots: ["/scoped/project"] });
    while (!(await index.step(10)).done) {}
    assert.equal(index.coverage.filesExcluded, 1);
    assert.equal(index.coverage.linesRead, 0);
    assert.equal(index.coverage.malformed, 0);
    assert.equal(index.fileMap.size, 0);
    const selected = join(root, "selected.jsonl");
    const records = [{ type: "session_meta", payload: { cwd: "/scoped/project", source: "cli" } }, { type: "response_item", timestamp, payload: { type: "message", role: "user", content: [{ type: "input_text", text: "wrong layout" }] } }];
    await writeFile(selected, records.map(JSON.stringify).join("\n"));
    const accepted = createDesignIndex({ files: [{ path: selected, source: "codex" }], since, until, projectRoots: ["/scoped/project"] });
    while (!(await accepted.step(10)).done) {}
    assert.equal(accepted.coverage.messages, 1);
    assert.equal(accepted.episodes[0].project, "/scoped/project");
  } finally { await rm(root, { recursive: true, force: true }); }
});
