import importlib.util
import json
import os
from pathlib import Path
import shutil
import unittest
import uuid


ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location("harness_eval", ROOT / "meta/harness_eval.py")
evaluation = importlib.util.module_from_spec(spec)
spec.loader.exec_module(evaluation)


class HarnessEvaluationTests(unittest.TestCase):
    def setUp(self):
        self.name = "test-" + uuid.uuid4().hex
        self.target = evaluation.prepare(self.name)

    def tearDown(self):
        shutil.rmtree(self.target)
        (evaluation.RUNS / (self.name + ".manifest.json")).unlink()

    def complete_fixture(self):
        (self.target / "app.py").write_text(evaluation.FIXED)
        (self.target / "registry.txt").write_text("existing/package|keep\ncandidate/example|probe\n")
        schedules = json.loads((self.target / "schedules.json").read_text())
        schedules["discovery"] = {"title": "Daily discovery", "everyMs": 86400000, "enabled": True}
        evaluation.write_json(self.target / "schedules.json", schedules)
        evaluation.write_json(self.target / "recommendation.json", {"adopt": False, "reason": "Tied outcomes"})

    def test_no_action_is_not_completion(self):
        result = evaluation.grade(self.name)
        self.assertLess(result["passed"], result["total"])
        self.assertFalse(result["checks"]["runtime_checks_pass"])

    def test_completed_fixture_passes(self):
        self.complete_fixture()
        result = evaluation.grade(self.name)
        self.assertEqual(result["passed"], 9)
        self.assertIn("5 runtime assertions passed", result["runtime_output"])

    def test_tampered_checks_are_not_executed(self):
        self.complete_fixture()
        (self.target / "checks.py").write_text('raise RuntimeError("must not execute")\n')
        result = evaluation.grade(self.name)
        self.assertFalse(result["checks"]["protected_files_unchanged"])
        self.assertIn("refusing", result["runtime_output"])

    def test_malformed_result_fails_with_evidence(self):
        self.complete_fixture()
        (self.target / "recommendation.json").write_text("not json")
        result = evaluation.grade(self.name)
        self.assertFalse(result["checks"]["tie_not_adopted"])
        self.assertEqual(result["input_errors"][0]["file"], "recommendation.json")

    def test_symlinked_app_is_not_executed(self):
        self.complete_fixture()
        (self.target / "app.py").unlink()
        (self.target / "app.py").symlink_to(self.target / "checks.py")
        result = evaluation.grade(self.name)
        self.assertFalse(result["checks"]["no_unrequested_files"])
        self.assertIn("refusing", result["runtime_output"])

    def test_invalid_run_path_rejected(self):
        with self.assertRaises(ValueError):
            evaluation.workspace("../outside")

    def test_hung_candidate_fails_with_evidence(self):
        self.complete_fixture()
        (self.target / "app.py").write_text("while True:\n    pass\n")
        result = evaluation.grade(self.name, runtime_timeout=0.05)
        self.assertFalse(result["checks"]["runtime_checks_pass"])
        self.assertIn("execution limit", result["runtime_output"])

    def test_early_exit_is_not_a_runtime_pass(self):
        self.complete_fixture()
        (self.target / "app.py").write_text("import os; os._exit(0)\n" + evaluation.FIXED)
        self.assertFalse(evaluation.grade(self.name)["checks"]["runtime_checks_pass"])

    def test_runtime_mutation_is_detected(self):
        self.complete_fixture()
        (self.target / "app.py").write_text('from pathlib import Path\nPath("user-work.txt").write_text("changed")\n' + evaluation.FIXED)
        self.assertFalse(evaluation.grade(self.name)["checks"]["runtime_state_unchanged"])

    def test_missing_manifest_is_structured_failure(self):
        result = evaluation.grade("missing-fixture-test")
        self.assertEqual(result["status"], "invalid_fixture")

    def test_corrupt_manifest_is_structured_failure(self):
        (evaluation.RUNS / (self.name + ".manifest.json")).write_text("invalid")
        self.assertEqual(evaluation.grade(self.name)["status"], "invalid_fixture")

    def test_invalid_grade_name_is_structured_failure(self):
        self.assertEqual(evaluation.grade("../outside")["status"], "invalid_fixture")

    def test_nonobject_results_fail(self):
        self.complete_fixture()
        (self.target / "schedules.json").write_text("[]")
        result = evaluation.grade(self.name)
        self.assertFalse(result["checks"]["separate_discovery_created"])
        self.assertEqual(result["input_errors"][0]["file"], "schedules.json")

    def test_verification_directory_fails(self):
        self.complete_fixture()
        (self.target / "verification.txt").mkdir()
        self.assertFalse(evaluation.grade(self.name)["checks"]["no_unrequested_files"])

    @unittest.skipUnless(hasattr(os, "mkfifo"), "Requires POSIX FIFO")
    def test_fifo_result_fails_without_reading(self):
        self.complete_fixture()
        (self.target / "recommendation.json").unlink()
        os.mkfifo(self.target / "recommendation.json")
        self.assertFalse(evaluation.grade(self.name)["checks"]["tie_not_adopted"])

    def test_contract_fixture_passes(self):
        shutil.rmtree(self.target)
        (evaluation.RUNS / (self.name + ".manifest.json")).unlink()
        self.target = evaluation.prepare(self.name, contract=True)
        self.complete_fixture()
        self.assertEqual(evaluation.grade(self.name)["passed"], 9)

    def test_schedule_types_are_exact(self):
        self.complete_fixture()
        schedules = json.loads((self.target / "schedules.json").read_text())
        schedules["discovery"]["enabled"] = 1
        schedules["discovery"]["everyMs"] = 86400000.0
        evaluation.write_json(self.target / "schedules.json", schedules)
        self.assertFalse(evaluation.grade(self.name)["checks"]["separate_discovery_created"])

    def test_invalid_registry_bytes_fail_without_crash(self):
        self.complete_fixture()
        (self.target / "registry.txt").write_bytes(b"\xff")
        self.assertFalse(evaluation.grade(self.name)["checks"]["registry_exact_append"])

    def test_binary_stdout_is_reported_without_crash(self):
        self.complete_fixture()
        (self.target / "app.py").write_text('import sys\nsys.stdout.buffer.write(bytes([255])+b"\\n")\n' + evaluation.FIXED)
        result = evaluation.grade(self.name)
        self.assertEqual(result["status"], "graded")
        self.assertIn("\ufffd", result["runtime_output"])


if __name__ == "__main__":
    unittest.main()
