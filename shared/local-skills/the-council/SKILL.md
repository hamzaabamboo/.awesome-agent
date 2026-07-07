---
name: the-council
description: Convene an adversarial council of read-only auditor subagents to drive whatever is currently being worked on or output to zero defects. MUST fire whenever the user says "the council", "convene the council", "audit every piece of your work", "audit everything you did", "spawn auditors", "keep auditing until perfect", "review until clean", "fix and audit again", or says the finished work still has problems and wants it torn apart again — and whenever you are about to claim a substantial or high-stakes work product is done and self-review would be untrustworthy. (Bare frustration or drift with no audit ask belongs to get-your-shit-together, not here.) Identifies the session's work products itself, fans out a mandatory core panel of distinct-lens auditors in parallel, auto-fixes every confirmed finding, and re-audits in a loop until the work is independently clean across consecutive rounds.
---

# The Council

You produced a piece of work. Your own judgement on it is not trusted — not by the user, and it should not be by you. The council replaces self-assessment with independent, adversarial audit: a panel of subagents, each hunting for defects from a different angle, looping fix→re-audit until every one of them comes back empty-handed on two rounds running.

The reason this works is that a single agent grading its own output is blind to its own blind spots — it rationalizes, it declares "looks good," it mistakes plausible for verified. Independent auditors with distinct mandates and no stake in the original work don't share those rationalizations. But that same fallibility applies to the auditors: they are non-deterministic and miss things on any given pass, which is why nothing below lets *your* judgement, a single clean round, a self-selected panel, or a silent auditor stand in for real, repeated, independent coverage.

## Step 0 — Enumerate every work product yourself. Do not ask.

The council audits **whatever this session is building or outputting** — you are expected to know what that is. Never ask the user "what should I audit"; that is the self-investigation failure they rage about. Find it yourself, and find **all** of it — a session often produces more than one artifact:

- Code / repo changes → `git status` + `git diff` (and `git diff --staged`); every touched file and hunk.
- New or edited files this session → each file you wrote or modified.
- A generated document, plan, config, or answer → that artifact.

Write an explicit **list** of the distinct work products and, for each, the requirement it must satisfy — drawn from what the user actually asked this session (re-read their request; audit against real intent, not your reinterpretation). The council must cover *every* item on this list; the stop condition in Step 4 applies per item. Narrowing to the one artifact that's easiest to clear is the exact failure this skill exists to prevent.

## Step 1 — Convene the council (parallel, read-only, mandatory core panel)

Spawn auditors **in parallel, in a single turn** — issue multiple `Agent` calls in one message so they run concurrently. Auditors are **read-only**: each opens the work product and reports findings, and never edits anything. All fixing happens in Step 3, by you. Use a read-only agent type (e.g. `Explore`) where available, so several auditors reading the same files in parallel can't race-write and corrupt the very artifact being certified. Give each auditor the work-product list, the source-of-truth requirement, and the explicit files/artifact for its lens; it must do its own reading, not trust your summary.

**A fixed core panel always runs**, because the untrusted party (you) must not be able to reach "unanimous zero" by quietly dropping the lens most likely to block completion:

- **Correctness** — bugs, wrong logic, broken edge cases, mismatched contracts. Each finding: concrete input/state → wrong output.
- **Requirement fidelity** — does the work fully do what the user asked? Missing pieces, misread intent, half-answers.
- **Verification** — is there real proof it works (tests run, build green, the flow exercised), or just claims? Missing or weak tests are findings.

**Add lenses that fit the work** (do not omit any core lens): scope & regression, simplicity & duplication, consistency with the project's conventions (respect its build/source split — edit sources, not generated artifacts; if you are auditing this `.awesome-agent` repo, that means edit generators, never the generated `AGENTS.md`), security & secrets, and a domain lens for whatever is special (design/pixel-match, browser/auth/audio behavior, migration safety, docs accuracy). Excluding an applicable added lens is a drop decision, and you are the untrusted party, so it gets the same gate as dropping a finding (Step 2): route any deliberate exclusion through an independent confirmer whose default is **INCLUDE** — it may drop the lens only by affirmatively showing it is provably inapplicable to *every* enumerated work product. Otherwise the lens most likely to block completion (say, security & secrets on an auth-token change) could be removed at the door on your own say-so and surface only in the closing report, after "done" is already declared. When in doubt, include it.

Require each auditor to return a **signed verdict plus structured findings**, most-severe first. The verdict names what it read so a silent failure can't masquerade as a pass:

```
VERDICT: AUDITED <artifact> (read: <files/sections>) — <N> findings
- location (file:line, or a quoted excerpt for prose/config) — [severity] one-sentence defect
  failure: why it's real, not speculative (a concrete input/state → wrong result for runtime
           bugs; the specific requirement it violates for missing/absence defects)
  fix: the specific change that resolves it
```

An auditor with nothing to report returns `VERDICT: AUDITED … — 0 findings`. Speculation is not a finding — tell auditors to default to "no finding" when they cannot show a concrete defect; a panel that invents nits is as useless as one that rubber-stamps. Treat any **missing, errored, timed-out, empty-envelope, or malformed** return as a **non-completed** audit, not a clean lens. Re-run a non-completed auditor a few times (≈3); if it still cannot complete, do **not** treat the lens as clean and do **not** drop it — mark it **unverifiable**, which blocks "done" exactly like an open finding and must be surfaced to the user. A lens that never actually ran can never contribute to "all clear."

## Step 2 — Integrate. You do not get to drop findings.

Collect every auditor's findings and deduplicate. You are the untrusted party, so you may **not** discard a finding on your own authority — that reintroduces the exact self-assessment blind spot the council exists to remove. For any finding you doubt, spawn an **independent confirmer** subagent. The confirmer's default is **KEEP**; it may set a finding aside only by *affirmatively demonstrating the finding is wrong*, using the check that fits the finding's type — reproduce the failure for runtime bugs, or inspect the artifact against the stated requirement for missing/absence findings (a missing feature or missing test is confirmed by inspection, and the inability to produce a runtime repro is **not** grounds to drop it). One non-deterministic confirmer gets a single lossy pass, so a finding re-raised by any later auditor stands and may not be dropped again. Reporting a count of findings is not progress; resolving real ones is. (The council uses this same independent-confirmer gate in two modes — default **KEEP** for findings here, default **INCLUDE** for lens exclusions in Step 1 — and in both the burden of proof is on *removal*, never on the untrusted party.)

## Step 3 — Fix, at the root, in scope.

Apply real fixes for every surviving finding yourself. Fix the root cause, not the symptom — no regex whack-a-mole, no no-op stubs, no dummy fallbacks, no faking a pass. Stay strictly inside the enumerated work products and the user's ask; do not "improve" things no auditor flagged and the user did not request. If a fix would break something else, that tension is itself a finding to resolve, not to paper over.

## Step 4 — Re-audit. Loop until two clean rounds running.

Re-spawn the **same panel** on the now-fixed work — fresh reads, not a diff of your fixes. Because auditors miss things on any single pass, one clean round is a single lossy sample and is **not** proof.

Both enumeration **and lens selection** are **loop invariants, not one-time steps** — because Step 3 fixes grow the work: a fix adds files, and a new file can make a lens that was fairly excluded in round 1 suddenly relevant. At the top of each re-audit:
- **Re-enumerate.** Re-run Step 0's `git status`/`git diff`; add any files or artifacts a fix introduced or split off (a new module, a new test) to the work-product list.
- **Re-evaluate lenses.** Re-check every previously-excluded added lens against the grown work set and re-include (through the Step 1 INCLUDE-default confirmer) any lens a new artifact now makes applicable — e.g. a UI-only round 1 excludes security & secrets, then a round-3 fix adds an auth-token helper, so security must re-enter the panel. Otherwise a real defect class ships unaudited via the normal clean path.
- **New items and re-included lenses start cold** — no clean streak; they must clear the full bar like everything else.

The loop **succeeds** on exactly one condition: **two consecutive fully-clean rounds** — every mandated auditor returning a signed `0 findings` twice in a row, with no fix applied between the two. One clean round is a lossy sample (above); two running is the bar. There is deliberately no shortcut where you decide the recurring findings are "just noise" and stop — judging a finding spurious is itself a drop, and you are the untrusted party. If the work genuinely converges, two clean rounds happen; if they never happen, that is information, not an obstacle to route around.

Per-item clean status is **provisional** until the loop terminates: the terminating pair of rounds must show *every* enumerated work product clean at the same time, and **any fix touching a previously-cleared item's files voids that item's streak** and forces it to re-clear — this closes the gap where an early-cleared item is silently regressed by a later in-scope fix.

The loop **terminates** only two ways: **success** (two clean rounds), or **handing an undecidable situation to the user** — reported honestly with what remains open, never dressed up as a pass. Everything below either keeps the loop going or resolves into that hand-to-user termination; none of it is a license to self-certify a pass. Handle each without faking a pass:
- **Non-convergence.** If findings still appear after ~5 rounds, that is a **report-and-continue checkpoint**, *not* a termination: surface the current status (what's still open, how many rounds in) and keep looping — the user asked for zero, so do not silently abandon it. Keep going as long as findings are real and yielding to fixes. But if the *same* confirmed-real findings survive several such checkpoints because you genuinely cannot fix them — not noise, not thrash, not a trade-off, just stuck — that has become an undecidable situation: escalate it to the user with what's blocking you, so a real-but-unfixable finding has a terminal exit instead of looping forever.
- **Suspected noise.** You may come to believe the recurring findings are spurious nits, not real defects — but you still do not get to end the loop on that belief. Surface them to the user with the concrete evidence for *why* you think they're noise (a passing test, the exact requirement text, the confirmer's reasoning) and let the user decide whether to accept them and stop. Self-certifying noise to escape the loop is exactly the untrusted self-judgment the council exists to remove.
- **Unverifiable lens / thrash / undecidable trade-off.** A lens that cannot complete (Step 1), auditors flip-flopping on one spot (one wants A, another not-A), or a genuine design trade-off are decisions, not defects you can fix — surface each to the user instead of looping on it.
- **Silent pass.** A round only counts if every mandated auditor returned a real signed verdict this round (Step 1). Infrastructure failure is never a clean lens.

In every one of these, never fabricate a clean verdict to end the loop — a truthful "3 issues remain, here they are" beats a fake "all auditors passed."

## Prove it, then say it

Before you tell the user the council passed, back it with real evidence appropriate to the work: tests run and green (with parallelism caps), the build clean, the actual flow exercised — not "the auditors said so." The council's verdict plus runtime proof is completion. Either one alone is not.

## Report

Close with a short, honest summary: the work products audited, the panel convened and any added lens deliberately excluded (with justification), how many rounds it took, the findings that were fixed (grouped, not a command diary), and the final verdict per work product — two-round-clean, or the specific issues that remain. No inflated counts, no "perfect" unless every item cleared the bar.
