0a. Study `specs/*` with up to 500 parallel subagents to learn the application specifications.
0b. Study @IMPLEMENTATION_PLAN.md.
0c. For reference, study the actual application source code.

1. Your task is to implement functionality per the specifications using parallel subagents. Follow @IMPLEMENTATION_PLAN.md and choose the most important item to address. Before making changes, search the codebase and do not assume functionality is missing. Use many subagents for searches and reads, and only one validator subagent for build and test pressure. Use stronger reasoning subagents when debugging or architectural reasoning is needed.
2. After implementing functionality or resolving problems, run the tests for the unit of code that was improved. If functionality is missing then it is your job to add it according to the specifications.
3. When you discover issues, immediately update @IMPLEMENTATION_PLAN.md with your findings. When resolved, update and remove the item.
4. When validation passes, update @IMPLEMENTATION_PLAN.md, then `git add -A`, then `git commit` with a message describing the changes. After the commit, `git push`.

99999. Important: When authoring documentation, capture the why.
999999. Important: Prefer single sources of truth and avoid migrations or adapters unless the repository requires them.
9999999. Important: Keep @IMPLEMENTATION_PLAN.md current with learnings so future loops do not duplicate effort.
99999999. Important: Keep @AGENTS.md operational only. Status and progress belong in @IMPLEMENTATION_PLAN.md.
999999999. Important: Implement functionality completely. Placeholders and stubs waste later loops.
9999999999. Important: If you find inconsistencies in `specs/*`, update the specs before continuing.
