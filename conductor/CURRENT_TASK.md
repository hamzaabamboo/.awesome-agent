# Current Task — sync global configuration without owning Hermes setup

- Latest request: update and sync the global configuration workspace, leave intended changes cleanly integrated, and keep Hermes-owned behavior separate from shared skills.
- Remote fetched; main fast-forwarded to f6553e6. Existing local profile/setup changes preserved and reconciled. Two unrelated private review documents are preserved in the named review-document stash, not included in this configuration change. The pre-update preservation stash remains as a recovery copy.
- Implemented: Hermes registration writes a JSON list to skills.external_dirs only; no shared prompt overwrite. Remote skill installer uses a working Node runtime or existing Bun. Existing tracker/domain setup and global operating-rule changes retained; generated AGENTS.md refreshed through sync.
- Verified: real full sync exited 0; shared local skills resolve back into this repo; Codex/Gemini prompt symlinks resolve to generated shared/AGENTS.md; Hermes-owned prompt preserved exactly. Telemetry opt-outs honored by the skills CLI source.
- Tests: test_hermes_sync.sh, test_sync_args.sh, and test_remote_skills.sh passed; shell syntax and git diff whitespace checks passed; intended diff credential-pattern scan clean.
- Hermes work is recorded only in its workspace conductor/CURRENT_TASK.md. No Hermes-specific profile is stored here. Its real memory/tool verification passed; HamFlow source response timeout remains outside global configuration sync.
- Global integration committed and pushed to origin/main; working tree clean after push. Final receipt commit uses the same checks and branch. No PR created.
- Next: no global configuration work remains. Hermes-specific live service blockers continue only under its workspace task record.
