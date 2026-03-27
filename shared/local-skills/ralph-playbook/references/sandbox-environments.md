# Sandbox Environments

Ralph-style autonomous loops should run in an isolated environment when possible.

Minimum guidance:

- treat the sandbox as the actual security boundary
- minimize credentials and network access
- avoid exposing browser cookies, SSH keys, and unrelated secrets
- prefer environments that are easy to recreate and observe

## Good local option

Docker-style local sandboxes are fine for prototyping and quick iteration when the operator understands the blast radius.

## Better hosted options

MicroVM-style hosted environments are closer to the intended security posture for unattended autonomous loops.

Useful properties:

- environment isolation
- explicit network controls
- filesystem persistence when needed
- resumability or snapshots
- enough CPU and RAM to run builds and tests reliably

## Operator rule

If the user asks for autonomous looping with broad permissions, call out the security tradeoff directly instead of burying it in setup steps.
