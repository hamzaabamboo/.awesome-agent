# Triage Labels

Keep the five default state-role names as advisory vocabulary. HamFlow-native label support is unverified; none of these values may be written to tasks or mapped to board columns.

| Canonical state role | HamFlow handling | Meaning |
| --- | --- | --- |
| `needs-triage` | Advisory only; not persisted | Maintainer needs to evaluate the issue |
| `needs-info` | Advisory only; not persisted | Waiting on the reporter for more information |
| `ready-for-agent` | Advisory only; not persisted | Fully specified for an agent |
| `ready-for-human` | Advisory only; not persisted | Requires human implementation |
| `wontfix` | Advisory only; not persisted | Will not be actioned |

The category roles `bug` and `enhancement` are also advisory only. Until native label support is verified and this mapping is updated, `/triage` may recommend roles but must not apply labels or change task state.
