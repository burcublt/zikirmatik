import contextlib
import importlib.util
import io
from pathlib import Path
import plistlib
import tempfile
import unittest
from unittest.mock import patch
from types import SimpleNamespace

ROOT=Path(__file__).resolve().parents[2]
spec=importlib.util.spec_from_file_location('build_ios_test',ROOT/'scripts/build_ios_test.py')
module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)

class IosTestBuildTests(unittest.TestCase):
 def setUp(self):
  self.temp=tempfile.TemporaryDirectory();self.addCleanup(self.temp.cleanup);self.root=Path(self.temp.name)
 def app(self,folder='Profile-iphoneos',debug=False,platform='iphoneos'):
  app=self.root/f'build/ios/{folder}/Runner.app';assets=app/'Frameworks/App.framework/flutter_assets';assets.mkdir(parents=True)
  (app/'Frameworks/App.framework/App').write_bytes(b'AOT test binary');(assets/'AssetManifest.bin').write_bytes(b'assets')
  if debug:(assets/'kernel_blob.bin').write_bytes(b'debug snapshot')
  (app/'Info.plist').write_bytes(plistlib.dumps({'DTPlatformName':platform,'CFBundleIdentifier':'com.test.current'}));return app
 def test_profile_output_is_selected_over_old_common_debug_output(self):
  correct=self.app();self.app('iphoneos',debug=True)
  self.assertEqual(module.profile_app(self.root),(correct,'com.test.current'))
 def test_debug_and_simulator_packages_are_rejected(self):
  app=self.app(debug=True)
  with self.assertRaises(ValueError):module.profile_app(self.root)
  (app/'Frameworks/App.framework/flutter_assets/kernel_blob.bin').unlink()
  (app/'Info.plist').write_bytes(plistlib.dumps({'DTPlatformName':'iphonesimulator','CFBundleIdentifier':'com.test.current'}))
  with self.assertRaises(ValueError):module.profile_app(self.root)
 def test_source_and_asset_changes_change_fingerprint(self):
  source=self.root/'lib/settings.dart';source.parent.mkdir();source.write_text('current picker')
  before=module.source_fingerprint(self.root);source.write_text('new picker');self.assertNotEqual(before,module.source_fingerprint(self.root))
  before=module.source_fingerprint(self.root);asset=self.root/'assets/calendar.json';asset.parent.mkdir();asset.write_text('{}');self.assertNotEqual(before,module.source_fingerprint(self.root))
 def test_concurrent_source_edit_prevents_install(self):
  self.app();source=self.root/'lib/settings.dart';source.parent.mkdir();source.write_text('before')
  def run(*args,**kwargs):source.write_text('edited while building');return SimpleNamespace(returncode=0)
  with patch.object(module.shutil,'which',return_value='/tools/flutter'),patch.object(module.subprocess,'run',side_effect=run) as calls,contextlib.redirect_stderr(io.StringIO()):
   self.assertEqual(module.main(['--device','phone'],root=self.root),2);self.assertEqual(calls.call_count,1)
 def test_build_only_records_provenance_without_installing(self):
  self.app()
  with patch.object(module.shutil,'which',return_value='/tools/flutter'),patch.object(module.subprocess,'run',return_value=SimpleNamespace(returncode=0)) as calls,contextlib.redirect_stdout(io.StringIO()):
   self.assertEqual(module.main([],root=self.root),0);self.assertEqual(calls.call_count,1)
   self.assertTrue((self.root/'build/ios/test-build.json').is_file())
if __name__=='__main__':unittest.main()
