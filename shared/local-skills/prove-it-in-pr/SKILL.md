---
name: prove-it-in-pr
description: Execute affected testing step by step, capture current screenshots or complete-flow videos, embed the proof in the reviewer-facing pull request, and reopen and proofread the rendered PR yourself. Use when the user invokes `$prove-it-in-pr`, asks for proof/evidence in a PR, wants testing documented step by step, requests screenshots/video attached or embedded in a PR, says “PR + proof,” or complains that evidence is local-only, stale, incomplete, unembedded, or not proofread.
---

# Prove It In PR

Make the pull request itself the verified evidence artifact. Testing, capture, upload, embedding, and rendered proofreading are one workflow.

## Authority Gate

- Inspect freely.
- Do not create or update a PR, comment, upload, push, deploy, or perform any external write unless the user explicitly authorizes that action in the current turn.
- If PR mutation is not authorized, complete all safe local preparation and return the exact pending mutation.
- Do not infer authority from an older request, existing branch, draft PR, or prior evidence.

## Preflight

1. Read the current PR, task/spec, branch diff, repository evidence rules, and affected user flows.
2. Fetch current branch and PR state before making readiness claims.
3. Resolve the required GitHub account, repository owner, author identity, and authenticated CLI account from current repo instructions and live auth state.
4. Stop before any external write when the active account or repository is wrong. Never upload first and correct identity later.
5. Record the current head and treat earlier evidence from another head as stale unless the visible behavior is proven unchanged.
6. Derive a step-by-step verification matrix from the actual change.
7. Include the happy path plus every relevant empty, validation, loading, error, permission, tenant, viewport, persistence, and regression state.
8. Use the exact repeat count or stability threshold the user specified.

## Test And Capture

For each matrix row:

1. Name the user-visible behavior being proved.
2. Establish the initial state.
3. Exercise the real user action through the canonical runtime.
4. Capture the action and final result.
5. Verify persistence or downstream output when relevant.
6. Inspect the capture yourself.
7. Mark the row passed only when the evidence shows the claimed result.
8. Do not advance to the next row while the current row, capture, or account check is wrong.

Use a headed browser for browser-visible flows. Unit tests, scripts, code inspection, API calls, console output, and logs are supporting evidence only.

Capture complete causal proof: before or initial state → action → result → persistence. A video that omits the result, a screenshot that hides the changed content, or a browser crash does not pass.

## Evidence Quality

- Keep screenshots readable, focused on the relevant state, and reasonably sized.
- Show full text and enough surrounding context to make the claim understandable.
- Use before/after or side-by-side evidence when the change is visual or textual.
- Capture every requested state, variant, viewport, and error path; never use one representative image to imply exhaustive coverage.
- Regenerate stale evidence after visible behavior changes.
- Never fabricate, crop around a defect, or treat blocked as passed.
- Review screenshots and videos for secrets, personal data, tokens, broken UI, stale copy, irrelevant tabs, and missing results before upload.

## Put Proof In The PR

- Keep media out of the repository.
- Upload through GitHub user attachments or the repository-required media host.
- Embed images directly in the PR body where the claim is described.
- Put video URLs on standalone lines.
- Prefer updating the PR body. Do not add or reply to comments unless explicitly requested in the current turn.
- Keep reviewer-facing text limited to the problem, implementation, verification steps, results, and evidence.
- Keep command diaries, internal approvals, agent reasoning, commit hashes used as status chatter, and local-only paths out of reviewer-facing text.
- Follow the repository’s required PR language. Keep chat in English; use Japanese only when the PR or project requires it.
- Rewrite the existing body into coherent sections. Never blindly append or concatenate new proof beneath stale text.
- Remove duplicated, obsolete, irrelevant, contradictory, or wrong-head evidence while preserving still-valid reviewer context.
- Keep every verification step and asset directly relevant to the current PR change.

Use this structure unless the repository specifies another:

```markdown
## What changed

## Verification

### 1. <User behavior>
- Initial state:
- Action:
- Result:
- Evidence:

### 2. <User behavior>
- Initial state:
- Action:
- Result:
- Evidence:

## Remaining risk
```

Do not paste unchecked boxes for work already complete. Do not claim coverage broader than the listed evidence.

## Rendered PR Proofread

After every PR update:

1. Reopen the actual rendered PR.
2. Confirm the correct PR, branch, head, title, and body are visible.
3. Read the complete rendered body line by line.
4. Open or inspect every embedded image and video target.
5. Look critically at the actual media instead of trusting its filename, upload result, or capture command.
6. Confirm media renders, belongs to the current change and account, shows the stated result, and appears beside the correct claim.
7. Check headings, order, links, language, wrapping, readability, relevance, duplicated sections, stale evidence, internal chatter, and unsupported claims.
8. Edit the existing PR body in place if anything is wrong.
9. Reopen and proofread again until the rendered PR is clean.

Raw Markdown, an API response, or successful upload is not rendered-proof evidence.

## Completion Gate

Do not call PR proof complete until:

- Every required matrix row has real evidence.
- Every capture was inspected.
- The authenticated account, repository, owner, and identity were verified before external writes.
- Every reviewer-facing asset is uploaded and embedded.
- The PR reflects the current head and behavior.
- The complete rendered PR was reopened and proofread.
- Every link and media item was verified.
- Remaining unverified behavior is stated explicitly.

Local proof is not PR proof. Uploaded proof is not embedded proof. Embedded proof is not proofread proof.
