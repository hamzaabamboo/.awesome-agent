---
name: the-council
description: Run a fresh third-party review of the actual current work product when the user invokes the council, requests an audit or review of current work, or independent review is required before a substantial or high-stakes delivery. Review only the in-scope deliverable and report confirmed defects.
---

# The Council

You produced a piece of work. Review it as an independent third party seeing it for the first time. Start from the requested deliverable, not from a generic audit template or previous conclusion. Read the actual artifact, decide what matters from what is present, and report only concrete defects tied to the user’s requirement.

## Step 0 — Establish the review target

1. Stop prior review conclusions and reread the latest direct user request plus the canonical current-task record.
2. Identify the requested deliverable and the acceptance conditions it must satisfy.
3. Include source files that implement that deliverable and generated artifacts only when they are user-facing or affect the behavior under review.
4. Exclude task ledgers, status receipts, tool output, unrelated dirty files, historical artifacts, and adjacent work unless the request makes them part of the deliverable.
5. Read each selected artifact from scratch at full useful scope. Do not rely on summaries, prior auditor claims, intended answers, or the diff alone.

Write a short target list before review. If the target is clear from the request and live state, do not ask the user to restate it. If it is genuinely ambiguous, stop and ask only the decision that changes the review target.

## Step 1 — Fresh third-party review

Use independent read-only reviewers when delegation is available and authorized. Give each reviewer the same target list, source-of-truth requirements, and raw artifacts, without suspected defects, prior conclusions, or a fixed lens checklist. Each reviewer must decide what to check after reading the artifact as a third party. When delegation is unavailable, perform one fresh pass yourself after resetting prior conclusions and judge the artifact as a third party; do not claim multiple independent verdicts.

Different perspectives are allowed only when a concrete risk in the selected artifact justifies them. Do not run correctness, security, simplicity, scope, or other canned checks merely because they exist. One complete independent review is enough when it covers the actual deliverable.

Require a signed verdict naming exactly what was read:

```
VERDICT: AUDITED <artifact> (read: <files/sections>) — <N> findings
- location (file:line, or quoted excerpt for prose/config) — [severity] concrete defect
  failure: the observed behavior or exact requirement violation
  fix: the specific in-scope change that resolves it
```

Use `VERDICT: AUDITED <artifact> (read: <files/sections>) — 0 findings` when no concrete defect is demonstrated. Speculation, taste, and checklist omissions are not findings. A missing, errored, timed-out, empty, or malformed review is incomplete, not clean; retry once only when a transient failure is plausible, then surface it as unverifiable.

Reviewer output is a hypothesis. Independently inspect every cited location and reproduce or verify each surviving finding with the canonical check before changing or closing it.

## Step 2 — Verify findings

Collect findings against the selected deliverable. Inspect every cited location and independently reproduce or verify each claimed defect with the canonical check. Fix confirmed defects. Keep an unverified claim as an evidence gap; do not turn it into a fix or a clean verdict. If a finding is disputed, use one focused independent confirmation rather than rerunning a generic panel.

## Step 3 — Fix, at the root, in scope.

Apply real fixes for every confirmed finding yourself. Fix the root cause, not the symptom. Stay inside the selected deliverable and the user's ask; do not change unrelated artifacts or "improve" things no finding requires. If a fix would break something else, verify that tension against the actual requirement before changing course.

## Step 4 — Fresh re-review after fixes

After each in-scope fix, re-establish the target list from the current request and live artifact state. Use fresh reads, without carrying forward the previous review's framing. One complete clean review is sufficient unless the active task explicitly requires a repeat threshold.

Do not repeat an unchanged review merely to make a finding disappear. If the same confirmed finding cannot be fixed in scope, the target becomes undecidable, or a review remains unverifiable, surface the exact evidence to the user.

## Prove it, then say it

Before saying the council passed, run the canonical checks appropriate to the selected artifact. Use runtime proof for runtime behavior, and tests, builds, or static checks only where they establish the requirement. Reviewer agreement is not proof.

## Report

Close with a short, honest summary: the actual deliverable reviewed, what was read, concrete findings fixed, remaining evidence gaps, and the final verdict. Do not report unrelated artifacts, canned lens counts, or a clean result unsupported by the selected artifact and canonical checks.
