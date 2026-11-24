#!/bin/bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

export DO_NOT_TRACK=1
export DISABLE_TELEMETRY=1
export PYTHONDONTWRITEBYTECODE=1
export OMP_NUM_THREADS=1
export OPENBLAS_NUM_THREADS=1

bash tests/test_remote_skills.sh
bash tests/test_sync_args.sh
bash tests/test_transform.sh
bash tests/test_prompt_unification.sh
bash tests/test_no_self_block.sh
bash tests/test_steer_reply_gate.sh
python3 -B tests/test_harness_eval.py
node --test --test-concurrency=1 tests/test_design_episodes.mjs
