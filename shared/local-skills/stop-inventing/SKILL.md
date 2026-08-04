---
name: stop-inventing
description: Read every authoritative reference completely and execute its requirements literally without inventing features, facts, data, constraints, fallbacks, interpretations, scope, or substitutions. Use when the user invokes `$stop-inventing`, says to stop inventing, tells the agent to read or follow all references, says the answer or implementation contradicts supplied sources, prohibits assumptions or invention, provides source-of-truth assets or examples, or requires exact conformance to existing documentation, designs, code, specifications, logs, sessions, or artifacts.
---

# Stop Inventing

Use the sources. Do not replace them with preference, memory, convention, or creative interpretation.

## Stop Before Acting

1. Stop implementation, diagnosis, planning, or recommendation work.
2. Update the project-owned current-task document with every active request, named reference, scope boundary, permission, prohibition, and required output.
3. Inventory every reference supplied, named, linked, attached, or clearly designated as source of truth.
4. Check each file or artifact size before reading it. For a file larger than 500 KB, use bounded sections or targeted extraction that still covers all relevant content; do not dump it wholesale.
5. Open and read every reference completely. For archives, enumerate and read every contained file. For documentation, read every directly relevant linked page. For code, read the surrounding architecture, types, callers, and tests required to understand the referenced behavior.
6. Inspect visual and runtime references directly with the appropriate viewer or headed surface. Metadata, filenames, OCR, DOM, logs, and descriptions do not substitute for looking at the artifact.

No task work resumes until the full reference set has been read.

## Build the Reference Contract

Record in the current-task document:

- authoritative source
- requirement derived from it
- exact target or affected surface
- required behavior or output
- prohibited behavior
- acceptance evidence
- unresolved contradiction or missing fact

Preserve full operational specificity without copying raw private chat, transcripts, credentials, session identifiers, or unrelated source content into project files.

## Follow Authority

Resolve conflicts in this order:

1. Latest direct user correction
2. User-provided or explicitly designated source-of-truth artifact
3. Current live runtime or data state
4. Current project specification and documentation
5. Existing implementation and tests
6. General convention or prior knowledge

Never override a higher-authority source because a lower-authority approach appears cleaner, easier, safer-looking, more conventional, or more elegant.

## Execute Literally

- Implement only requirements supported by the user or authoritative references.
- Preserve names, values, structure, order, states, behavior, content, and scope specified by the sources.
- Do not add speculative features, placeholder content, dummy data, hardcoded fallbacks, hidden defaults, inferred records, invented copy, or unrelated polish.
- Do not silently narrow exhaustive terms or replace exact output with a representative sample.
- Do not reinterpret an explicit implementation request as a plan, audit, test report, or recommendation.
- Do not reopen settled decisions unless newer authoritative evidence contradicts them.
- Do not ask the user for information already available in the references, code, history, live state, or named artifacts.
- Use judgment only to connect explicit requirements into a technically valid implementation. Do not use judgment to change what was requested.

When a required fact is absent, leave it blank, preserve an unresolved state, or ask for the single missing decision. Never fabricate it.

## Handle Contradictions

If authoritative sources conflict:

1. Re-read the conflicting passages or states.
2. Check whether a newer direct correction resolves the conflict.
3. Preserve and execute every unaffected requirement.
4. State the exact unresolved conflict and its implementation impact.
5. Ask only when no authoritative resolution exists and choosing would materially change the result.

## Verify Against Sources

1. Compare the completed artifact against every reference-contract item.
2. Inspect the real output on the surface the user will check.
3. Verify exhaustive scope item by item when the request requires all or exact coverage.
4. Remove every unsupported addition discovered during comparison.
5. Report any reference item still unverified or blocked.

No source-by-source conformance check means no completion claim.
