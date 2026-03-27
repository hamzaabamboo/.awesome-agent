# SKILLS SYSTEM

Use `skills.sh` as the source of truth for non-local skills.

## Usage

- Discover remote skills at `https://skills.sh/`
- `./meta/sync.sh --yes` should install all remote `skills.sh` entries automatically
- Install remote skill repos manually only if you are debugging with `npx skills add <owner/repo>`
- Use repo-local custom skills directly from this repo-managed setup
- This repo should only store local custom skills and local skill tests
- Do not vendor or copy skills that already live on `skills.sh`
