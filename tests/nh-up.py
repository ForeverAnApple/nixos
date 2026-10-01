#!/usr/bin/env python3
import json
import os
from pathlib import Path
import pty
import select
import subprocess
import tempfile
import time
import unittest

SCRIPT = Path(__file__).resolve().parents[1] / 'modules/home/core/nh-up.sh'
CLOSURE = '/nix/store/' + 'a' * 32 + '-system'
LOCK = {'version': 7, 'root': 'root', 'nodes': {
    'root': {'inputs': {'example': 'example'}},
    'example': {'locked': {'type': 'github', 'owner': 'example',
                           'repo': 'example', 'rev': 'old', 'url': 'https://example.invalid/latest'}},
}}
NIX = '''#!/usr/bin/env python3
import json, os, pathlib, sys
with open('calls', 'a') as f:
    f.write(json.dumps(sys.argv[1:]) + '\\n')
if sys.argv[1:3] == ['flake', 'update']:
    if os.environ['SCENARIO'] == 'mutable' and sys.argv[3:] == ['--refresh'] and not pathlib.Path('mutable-repaired').exists():
        print('error: mismatch in field \"narHash\"', file=sys.stderr)
        print("error: mismatch in field 'narHash' of input \" + json.dumps({'url': 'https://example.invalid/latest'}, separators=(',', ':')), file=sys.stderr)
        sys.exit(1)
    if os.environ['SCENARIO'] == 'mutable':
        pathlib.Path('mutable-repaired').touch()
    p = pathlib.Path('flake.lock')
    lock = json.loads(p.read_text())
    lock['nodes']['example']['locked']['rev'] = 'new'
    p.write_text(json.dumps(lock))
    sys.exit(1 if os.environ['SCENARIO'] == 'update-failure' else 0)
scenario = os.environ['SCENARIO']
if scenario.startswith('repair'):
    old = 'sha256-' + 'A' * 43 + '='
    new = 'sha256-' + 'B' * 43 + '='
    text = pathlib.Path('package.nix').read_text()
    if scenario == 'repair-ambiguous':
        print("error: hash mismatch in fixed-output derivation '/nix/store/" + 'c' * 32 + "-fixture.drv':\\n         specified: sha256-" + 'C' * 43 + "=\\n              got:    sha256-" + 'D' * 43 + "=", file=sys.stderr)
    if old in text:
        print("error: hash mismatch in fixed-output derivation '/nix/store/" + 'b' * 32 + "-fixture.drv':\\n         specified: " + old + "\\n              got:    " + new, file=sys.stderr)
        sys.exit(1)
    if scenario == 'repair-multifile':
        second = pathlib.Path('second.nix')
        if 'C' * 43 in second.read_text():
            print("error: hash mismatch in fixed-output derivation '/nix/store/" + 'c' * 32 + "-fixture.drv':\\n         specified: sha256-" + 'C' * 43 + "=\\n              got:    sha256-" + 'D' * 43 + "=", file=sys.stderr)
        sys.exit(1)
    if scenario == 'repair-failure':
        sys.exit(1)
    if scenario == 'repair-conflict':
        pathlib.Path('package.nix').write_text(text + '# concurrent edit\\n')
        sys.exit(1)
if os.environ['SCENARIO'] in ['build-failure', 'hash-mismatch']:
    if os.environ['SCENARIO'] == 'hash-mismatch':
        print("error: hash mismatch in fixed-output derivation '/nix/store/" + 'b' * 32 + "-fixture.drv':\\n         specified: sha256-" + 'A' * 43 + "=\\n              got:    sha256-" + 'B' * 43 + "=", file=sys.stderr)
    sys.exit(1)
print(os.environ['CLOSURE'])
'''


class UpdateSafety(unittest.TestCase):
    def run_script(self, scenario, args=(), approve=False, expected_source=None, nh_cmd='nh os'):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            repo = root / 'nixos'
            repo.mkdir()
            bin_dir = root / 'bin'
            bin_dir.mkdir()
            original = json.dumps(LOCK)
            (repo / 'flake.lock').write_text(original)
            source = 'url = "https://example.invalid/package";\nhash = "sha256-' + 'A' * 43 + '=";\n'
            (repo / 'package.nix').write_text(source)
            if scenario == 'repair-multifile':
                (repo / 'second.nix').write_text(source.replace('A' * 43, 'C' * 43))
            if scenario == 'repair-duplicate':
                (repo / 'duplicate.nix').write_text(source)
            subprocess.run(['git', 'init', '-q', str(repo)], check=True)
            subprocess.run(['git', '-C', str(repo), 'add', '.'], check=True)
            commands = {
                'nix': NIX,
                'nh': '''#!/usr/bin/env python3
import json,os,sys
with open("calls", "a") as f:
    f.write(json.dumps(["nh", *sys.argv[1:]]) + "\\n")
sys.exit(1 if os.environ["SCENARIO"] == "activation-failure" else 0)
''',
                'readlink': '#!/bin/sh\nprintf "%s\\n" "$CLOSURE"\n',
            }
            for name, content in commands.items():
                path = bin_dir / name
                path.write_text(content)
                path.chmod(0o755)
            env = os.environ | {
                'HOME': directory, 'PATH': str(bin_dir) + ':' + os.environ['PATH'],
                'SCENARIO': scenario, 'CLOSURE': CLOSURE, 'NH_CMD': nh_cmd,
            }
            command = ['bash', str(SCRIPT), *args]
            if approve:
                master, slave = pty.openpty()
                process = subprocess.Popen(command, env=env, stdin=slave,
                                           stdout=slave, stderr=slave)
                os.close(slave)
                output = b''
                answered = False
                prompts = 0
                deadline = time.monotonic() + 10
                try:
                    while process.poll() is None and time.monotonic() < deadline:
                        if select.select([master], [], [], 0.1)[0]:
                            try:
                                output += os.read(master, 65536)
                            except OSError:
                                break
                            if output.count(b'Type approve:') > prompts:
                                os.write(master, b'reject\n' if approve == 'reject' else b'approve\n')
                                answered = True
                                prompts += 1
                    process.wait(timeout=2)
                    self.assertTrue(answered, output.decode(errors='replace'))
                    code = process.returncode
                finally:
                    if process.poll() is None:
                        process.kill()
                        process.wait()
                    os.close(master)
            else:
                result = subprocess.run(command, env=env, capture_output=True,
                                        text=True, timeout=10)
                code = result.returncode
            calls_path = repo / 'calls'
            calls = [json.loads(line) for line in calls_path.read_text().splitlines()] if calls_path.exists() else []
            if scenario == 'repair-multifile':
                self.assertEqual((repo / 'second.nix').read_text(), source.replace('A' * 43, 'C' * 43))
            actual_source = (repo / 'package.nix').read_text()
            if expected_source == 'repaired':
                self.assertEqual(actual_source, source.replace('A' * 43, 'B' * 43))
            elif expected_source == 'concurrent':
                self.assertEqual(actual_source, source.replace('A' * 43, 'B' * 43) + '# concurrent edit\n')
            else:
                self.assertEqual(actual_source, source)
            return code, (repo / 'flake.lock').read_text() != original, calls

    def test_default_rebuild_uses_existing_lock(self):
        code, changed, calls = self.run_script('success', ['--no-update'])
        self.assertEqual(code, 0)
        self.assertFalse(changed)
        self.assertEqual(calls[0][0], 'build')
        self.assertIn('--no-update-lock-file', calls[0])
        self.assertEqual(calls[-1], ['nh', 'os', 'switch', CLOSURE])

    def test_default_updates_and_activates_approved_closure(self):
        code, changed, calls = self.run_script('success', approve=True)
        self.assertEqual(code, 0)
        self.assertTrue(changed)
        self.assertEqual(calls[0], ['flake', 'update', '--refresh'])
        self.assertEqual(calls[-1], ['nh', 'os', 'switch', CLOSURE])

    def test_noninteractive_update_refused(self):
        code, changed, calls = self.run_script('success', ['--update-input', 'example'])
        self.assertNotEqual(code, 0)
        self.assertFalse(changed)
        self.assertEqual(calls, [['flake', 'update', 'example', '--refresh']])

    def test_failed_update_restores_lock(self):
        code, changed, _ = self.run_script('update-failure', ['--update'])
        self.assertNotEqual(code, 0)
        self.assertFalse(changed)

    def test_approved_update_success_preserves_candidate(self):
        code, changed, _ = self.run_script('success', ['--update-input', 'example'], True)
        self.assertEqual(code, 0)
        self.assertTrue(changed)

    def test_approved_update_failed_build_restores_lock(self):
        code, changed, _ = self.run_script('build-failure', ['--update'], True)
        self.assertNotEqual(code, 0)
        self.assertFalse(changed)

    def test_approved_update_failed_activation_restores_lock(self):
        code, changed, _ = self.run_script('activation-failure', ['--update'], True)
        self.assertNotEqual(code, 0)
        self.assertFalse(changed)

    def test_hash_mismatch_does_not_repair_source(self):
        code, changed, calls = self.run_script('hash-mismatch', ['--no-update'])
        self.assertNotEqual(code, 0)
        self.assertFalse(changed)
        self.assertEqual(len(calls), 1)

    def test_approved_hash_repair_retries_real_source_and_exact_closure(self):
        code, changed, calls = self.run_script('repair-success', ['--no-update'], True, 'repaired')
        self.assertEqual(code, 0)
        self.assertFalse(changed)
        self.assertEqual(sum(c[0] == 'build' for c in calls), 2)
        self.assertEqual(calls[-1], ['nh', 'os', 'switch', CLOSURE])

    def test_rejected_hash_repair_keeps_source_unchanged(self):
        code, changed, calls = self.run_script('repair-success', ['--no-update'], 'reject')
        self.assertNotEqual(code, 0)
        self.assertFalse(changed)
        self.assertEqual(len(calls), 1)

    def test_hash_repair_and_lock_restore_on_subsequent_build_failure(self):
        code, changed, calls = self.run_script('repair-failure', approve=True)
        self.assertNotEqual(code, 0)
        self.assertFalse(changed)
        self.assertFalse(any(c[0] == 'nh' for c in calls))

    def test_multiple_hash_edits_and_lock_all_restore_after_failure(self):
        code, changed, calls = self.run_script('repair-multifile', approve=True)
        self.assertNotEqual(code, 0)
        self.assertFalse(changed)
        self.assertEqual(sum(c[0] == 'build' for c in calls), 3)

    def test_rollback_preserves_concurrent_source_edit(self):
        code, changed, calls = self.run_script('repair-conflict', ['--no-update'], True, 'concurrent')
        self.assertNotEqual(code, 0)
        self.assertFalse(changed)
        self.assertFalse(any(c[0] == 'nh' for c in calls))

    def test_mutable_input_failure_uses_targeted_refresh_then_full_retry(self):
        code, changed, calls = self.run_script('mutable', approve=True)
        self.assertEqual(code, 0)
        self.assertTrue(changed)
        self.assertEqual(calls[:3], [['flake', 'update', '--refresh'],
                                    ['flake', 'update', 'example', '--refresh'],
                                    ['flake', 'update', '--refresh']])

    def test_ambiguous_diagnostics_and_duplicate_source_refuse_edits(self):
        for scenario in ['repair-ambiguous', 'repair-duplicate']:
            with self.subTest(scenario=scenario):
                code, changed, calls = self.run_script(scenario, ['--no-update'])
                self.assertNotEqual(code, 0)
                self.assertFalse(changed)
                self.assertEqual(len(calls), 1)

    def test_invalid_input_name_rejected_before_commands(self):
        code, changed, calls = self.run_script('success', ['--update-input', 'example; touch injected'])
        self.assertNotEqual(code, 0)
        self.assertFalse(changed)
        self.assertEqual(calls, [])

    def test_passthrough_cannot_bypass_review_or_select_another_host(self):
        for args in [['--', '--update'], ['-H', 'other'],
                     ['--override-input', 'example', 'github:other/source'],
                     ['other-flake'], ['--no-validate']]:
            with self.subTest(args=args):
                code, changed, calls = self.run_script('success', args)
                self.assertNotEqual(code, 0)
                self.assertFalse(changed)
                self.assertEqual(calls, [])

    def test_short_update_flag_still_requires_review(self):
        code, changed, calls = self.run_script('success', ['-u'])
        self.assertNotEqual(code, 0)
        self.assertFalse(changed)
        self.assertEqual(calls, [['flake', 'update', '--refresh']])

    def test_darwin_selects_matching_configuration_and_exact_closure(self):
        code, changed, calls = self.run_script('success', ['--no-update'], nh_cmd='nh darwin')
        self.assertEqual(code, 0)
        self.assertFalse(changed)
        self.assertIn('darwinConfigurations', calls[0][1])
        self.assertEqual(calls[-1], ['nh', 'darwin', 'switch', CLOSURE])

    def test_safe_flags_activate_only_prebuilt_closure(self):
        code, changed, calls = self.run_script('success', ['--no-update', '--verbose', '--ask'])
        self.assertEqual(code, 0)
        self.assertFalse(changed)
        self.assertEqual(calls[-1], ['nh', 'os', 'switch', '--verbose', '--ask', CLOSURE])


if __name__ == '__main__':
    unittest.main()
