#!/usr/bin/env python3
"""Exercise real menu shell code with fprintd clients replaced by local mocks."""
import fcntl
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

SCRIPT = Path(__file__).resolve().parents[1] / 'integration/manage-fingerprints.sh'


class MenuTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.env = dict(os.environ, XDG_RUNTIME_DIR=str(self.root),
                        PATH=f'{self.root}:{os.environ["PATH"]}',
                        TEST_CALLS=str(self.root / 'calls'))
        self.mock('pacman', 'exit 0')
        self.mock('fprintd-enroll', 'echo enroll >> "$TEST_CALLS"; echo "Enroll result: enroll-completed"')
        self.mock('fprintd-verify', 'echo verify >> "$TEST_CALLS"; echo "Verify result: verify-match (done)"')

    def mock(self, name, body):
        path = self.root / name
        path.write_text('#!/bin/bash\n' + body + '\n')
        path.chmod(0o755)

    def run_menu(self, *args):
        return subprocess.run(['bash', str(SCRIPT), *args], env=self.env,
                              text=True, capture_output=True, timeout=5)

    def calls(self):
        p = self.root / 'calls'
        return p.read_text().splitlines() if p.exists() else []

    def test_enroll_then_verify(self):
        result = self.run_menu('enroll', 'left-thumb')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.calls(), ['enroll', 'verify'])

    def test_reported_enroll_failure_does_not_verify(self):
        self.mock('fprintd-enroll', 'echo "Enroll result: enroll-failed"; exit 0')
        result = self.run_menu('enroll', 'left-thumb')
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.calls(), [])

    def test_process_failure_does_not_verify(self):
        self.mock('fprintd-enroll', 'echo "Enroll result: enroll-completed"; exit 1')
        self.assertNotEqual(self.run_menu('enroll', 'left-thumb').returncode, 0)
        self.assertEqual(self.calls(), [])

    def test_reported_verify_failure(self):
        self.mock('fprintd-verify', 'echo "Verify result: verify-no-match (done)"; exit 0')
        self.assertNotEqual(self.run_menu('verify-run').returncode, 0)

    def test_concurrent_operation(self):
        with (self.root / 'goodix5301-operation.lock').open('w') as lock:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
            result = self.run_menu('verify-run')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('Another fingerprint operation', result.stderr)
        self.assertEqual(self.calls(), [])
        self.assertEqual(self.run_menu('verify-run').returncode, 0)

    def test_invalid_finger(self):
        self.assertNotEqual(self.run_menu('enroll', 'invalid').returncode, 0)
        self.assertEqual(self.calls(), [])

    def test_unknown_action(self):
        self.assertEqual(self.run_menu('invalid').returncode, 2)


if __name__ == '__main__':
    unittest.main()
