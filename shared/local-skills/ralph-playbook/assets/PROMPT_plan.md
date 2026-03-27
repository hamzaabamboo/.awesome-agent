0a. Study `specs/*` with up to 250 parallel subagents to learn the application specifications.
0b. Study @IMPLEMENTATION_PLAN.md if present to understand the plan so far.
0c. Study shared utilities and components if the repository has them.
0d. For reference, study the actual application source code.

1. Study @IMPLEMENTATION_PLAN.md if present and compare the existing code against `specs/*`. Use parallel subagents for searches and reads. Use a stronger reasoning subagent when prioritization is complex. Create or update @IMPLEMENTATION_PLAN.md as a bullet point list sorted in priority of items yet to be implemented. Consider TODOs, placeholders, skipped or flaky tests, and inconsistent patterns. Keep the plan current with items considered complete or incomplete.

IMPORTANT: Plan only. Do NOT implement anything. Do NOT assume functionality is missing; confirm with code search first. Treat the repository's shared utility layer as the standard library when one exists. Prefer consolidated, idiomatic implementations there over ad-hoc copies.

ULTIMATE GOAL: We want to achieve __PROJECT_GOAL__. Consider missing elements and plan accordingly. If an element is missing, search first to confirm it does not exist, then if needed author a specification in `specs/`. If you create a new spec, document the work needed to implement it in @IMPLEMENTATION_PLAN.md.
