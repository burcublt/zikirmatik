import importlib.util
from pathlib import Path
import tempfile
import sys
import base64
import unittest

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'scripts'))
import check_ios_release

spec = importlib.util.spec_from_file_location('release_builder', ROOT / 'scripts/build_release.py')
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)

class ReleaseConfigTests(unittest.TestCase):
    def config(self, platform):
        prefix = platform.upper()
        return {('ANDROID_APPLICATION_ID' if platform == 'android' else 'IOS_BUNDLE_ID'): 'com.testpublisher.zikirmatik',
            f'ADMOB_{prefix}_APP_ID': 'ca-app-pub-1111111111111111~1111111111',
            f'ADMOB_{prefix}_NATIVE': 'ca-app-pub-1111111111111111/2222222222',
            f'ADMOB_{prefix}_BANNER': 'ca-app-pub-1111111111111111/3333333333'}
    def test_rejects_sample_ids_and_example_bundle(self):
        cfg = self.config('ios')
        cfg['IOS_BUNDLE_ID'] = 'com.example.zikirmatik'
        cfg['ADMOB_IOS_APP_ID'] = 'ca-app-pub-3940256099942544~1458002511'
        errors = module.validate('ios', cfg)
        self.assertTrue(any('IOS_BUNDLE_ID' in e for e in errors))
        self.assertTrue(any('ADMOB_IOS_APP_ID' in e for e in errors))
    def test_rejects_mixed_publishers(self):
        cfg = self.config('ios'); cfg['ADMOB_IOS_BANNER'] = 'ca-app-pub-2222222222222222/3333333333'
        self.assertTrue(any('yayıncı' in e for e in module.validate('ios', cfg)))
    def test_valid_ios_format_and_no_config_injection(self):
        cfg = self.config('ios')
        self.assertEqual(module.validate('ios', cfg), [])
        cfg['IOS_BUNDLE_ID'] += '\nOTHER_SETTING=1'
        self.assertTrue(module.validate('ios', cfg))
    def test_android_requires_upload_signing_and_rejects_debug(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp); (root / 'android').mkdir()
            cfg = self.config('android')
            self.assertTrue(module.validate('android', cfg, root))
            keyfile = root / 'android/upload.jks'; keyfile.write_bytes(b'fixture only; no actual key')
            props = root / 'android/key.properties'
            props.write_text('storeFile=upload.jks\nstorePassword=fixture\nkeyPassword=fixture\nkeyAlias=androiddebugkey\n')
            self.assertTrue(module.validate('android', cfg, root))
            props.write_text(props.read_text().replace('androiddebugkey','upload'))
            self.assertEqual(module.validate('android', cfg, root), [])
    def test_xcode_configuration_must_match_dart_release_values(self):
        cfg = self.config('ios')
        encoded = ','.join(base64.b64encode(f'{k}={v}'.encode()).decode() for k,v in cfg.items())
        env = {'DART_DEFINES': encoded, 'PRODUCT_BUNDLE_IDENTIFIER': cfg['IOS_BUNDLE_ID'],
            'ADMOB_IOS_APP_ID': cfg['ADMOB_IOS_APP_ID']}
        self.assertEqual(check_ios_release.validate_environment(env), [])
        env['ADMOB_IOS_APP_ID'] = 'different'
        self.assertTrue(check_ios_release.validate_environment(env))
    def test_xcode_rejects_malformed_or_missing_defines(self):
        self.assertTrue(check_ios_release.validate_environment({'DART_DEFINES':'%%%'}))
        self.assertTrue(check_ios_release.validate_environment({}))
    def test_missing_configuration_does_not_invoke_flutter(self):
        with tempfile.TemporaryDirectory() as tmp:
            self.assertEqual(module.main(['--platform','ios','--config',str(Path(tmp)/'missing.json'),'--check-only']), 2)

if __name__ == '__main__':
    unittest.main()
