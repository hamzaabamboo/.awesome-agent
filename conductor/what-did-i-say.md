# What Did I Say

## Objective

Create two repo-local skills and a universal skill-invocation rule that prevent visual evidence, rapid-fire instructions, cumulative requirements, and skill gates from being ignored.

Current request: recover every active instruction concerning all services from the actual Codex and Claude user-message history, reconcile it, and answer without guessing.

Latest correction: the two-week Codex and Claude history read, complete skill-invocation audit, failure analysis, holistic reasoning, literal execution, and current-task documentation are mandatory for every skill invocation, not only `what-did-i-say` and not only the current session.

## Active requirements

- Create `look-at-the-screen`.
- Require direct inspection of every relevant supplied or rendered visual artifact before visual reasoning, changes, verification, or completion claims.
- Create `what-did-i-say` using that exact normalized skill name.
- Create `stop-inventing`.
- Require complete reading of every referenced source before action, then literal conformance to those references without invented requirements, features, data, fallbacks, interpretations, or substitutions.
- Re-read every direct user request in the current session before continuing when instructions arrive rapidly or the user reports missed requirements.
- Read the complete request stream, reason across it as one evolving specification, and execute technically coherent authorized instructions literally.
- Maintain an ordered todo containing every active request, dependency, skill gate, artifact, permission, prohibition, status, next action, and verification target.
- Document the complete current task in a project-owned file and keep it updated throughout execution.
- Apply current-task documentation to every skill invocation through the central skill-system policy.
- For every skill invocation, read every direct user message from Codex and Claude sessions covering the previous two weeks, identify every skill invocation and subsequent failure, reconcile that history with the complete current session, preserve literal operative wording, and execute the resulting requirements.
- Use the past two weeks of Codex and Claude history to identify generalized skill-invocation failures without persisting raw history, quotes, or session identifiers.
- Keep raw chat content and private history out of Git-managed artifacts unless explicitly requested.
- Do not commit, push, deploy, open a PR, or upload anything in this turn.
- Install the created skills into the managed agent environments so they appear in the skill interface; local configuration sync is authorized as the required completion step.

## Status

- `look-at-the-screen`: implemented; validation passed.
- `what-did-i-say`: implemented; incorporating current-task documentation requirement.
- `stop-inventing`: implemented; validation passed.
- Universal every-skill documentation policy: implemented in `shared/skill_system.md`.
- Two-week Codex and Claude audit: completed; temporary extracted history deleted.
- Managed-agent sync: completed; all three skills generated under `.build/skills`, installed under `~/.agent/skills`, and linked under `~/.agents/skills`.
- Cross-session every-skill requirement: implemented, validated, synced, and verified in generated and Claude-installed skill targets.

## Verification

- Validate both skill folders with the Skill Creator validator.
- Inspect all new and modified task files for raw chat quotes, private history, timestamps, and session identifiers.
- Inspect Git status and diff; preserve pre-existing user changes.
