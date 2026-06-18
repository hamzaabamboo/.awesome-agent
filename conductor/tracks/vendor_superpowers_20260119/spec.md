# Specification: Vendor External Dependencies (Archived)

## Status

Superseded by the current `skills.sh` remote-skill model.

## Current Architecture

- Remote skills come from `shared/remote-skills.txt`.
- Remote skills install through `meta/install-remote-skills.sh`.
- Third-party remote skills should not be vendored into this repo.
- Repo-local custom skills live under `shared/local-skills/`.

The earlier vendoring and Claude plugin marketplace/cache model is no longer active.
