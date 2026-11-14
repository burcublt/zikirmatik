#!/usr/bin/env python3
"""Build current sources in Profile mode; optionally install on an explicit device.

Never uploads to a store or changes source/configuration. Rejects debug snapshots
and concurrent source edits so a stale test package is not silently installed.
"""
import argparse
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import plistlib
import shutil
import subprocess
import sys

ROOT=Path(__file__).resolve().parents[1]

def source_fingerprint(root):
    files=[]
    for folder in ('lib','assets','ios/Runner'):
        for path in (root/folder).rglob('*'):
            if not path.is_file():continue
            name=path.name
            if name.startswith('app_localizations') and path.suffix=='.dart':continue
            if name in ('GeneratedPluginRegistrant.h','GeneratedPluginRegistrant.m'):continue
            files.append(path)
    files.extend(root/name for name in ('pubspec.yaml','pubspec.lock','ios/Runner.xcodeproj/project.pbxproj','ios/Runner.xcodeproj/xcshareddata/xcschemes/Runner.xcscheme','ios/Flutter/Debug.xcconfig','ios/Flutter/Release.xcconfig','ios/Flutter/Environment.xcconfig','ios/Flutter/Environment.local.xcconfig') if (root/name).is_file())
    entries={str(path.relative_to(root)):hashlib.sha256(path.read_bytes()).hexdigest() for path in sorted(set(files))}
    return hashlib.sha256(json.dumps(entries,sort_keys=True).encode()).hexdigest()

def profile_app(root):
    candidates=[root/'build/ios/Profile-iphoneos/Runner.app',root/'build/ios/iphoneos/Runner.app']
    for app in candidates:
        if not app.is_dir():continue
        assets=app/'Frameworks/App.framework/flutter_assets'
        if (assets/'kernel_blob.bin').exists():raise ValueError('Debug paketi bulundu; Profile paketi kurulmadı.')
        if not (app/'Frameworks/App.framework/App').is_file() or not (assets/'AssetManifest.bin').is_file():raise ValueError('Profile paketinin AOT/asset çıktısı eksik.')
        info=plistlib.loads((app/'Info.plist').read_bytes())
        if info.get('DTPlatformName')!='iphoneos' or not info.get('CFBundleIdentifier'):raise ValueError('Fiziksel iPhone paketi gerekli.')
        return app,info['CFBundleIdentifier']
    raise ValueError('Yeni Profile paketi bulunamadı.')

def main(argv=None,root=ROOT):
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--flutter',default=os.environ.get('FLUTTER_BIN','flutter'))
    parser.add_argument('--device',help='Optional explicit iPhone UDID; without this flag only builds.')
    args=parser.parse_args(argv)
    flutter=shutil.which(args.flutter)
    if flutter is None:
        print('Flutter bulunamadı; --flutter ile tam yolu verin.',file=sys.stderr);return 2
    before=source_fingerprint(root)
    env=dict(os.environ);env['BYPASS_PERMISSION_LOCATION_ALWAYS']='1'
    result=subprocess.run([flutter,'build','ios','--profile','--no-pub'],cwd=root,env=env)
    if result.returncode:return result.returncode
    if before!=source_fingerprint(root):
        print('Derleme sırasında kaynak değişti; kurulum durduruldu. Güncel kaynaklarla yeniden çalıştırın.',file=sys.stderr);return 2
    try:app,bundle=profile_app(root)
    except (ValueError,OSError,plistlib.InvalidFileException) as error:
        print(str(error),file=sys.stderr);return 2
    record={'builtAt':datetime.now(timezone.utc).isoformat(),'sourceFingerprint':before,'bundleId':bundle,'appPath':str(app),'dartBinarySha256':hashlib.sha256((app/'Frameworks/App.framework/App').read_bytes()).hexdigest()}
    manifest=root/'build/ios/test-build.json';manifest.parent.mkdir(parents=True,exist_ok=True);manifest.write_text(json.dumps(record,indent=2)+'\n')
    print('Güncel kaynak ve bağımsız açılabilen Profile paketi doğrulandı: '+str(app))
    if args.device:
        result=subprocess.run(['xcrun','devicectl','device','install','app','--device',args.device,str(app),'--timeout','60'],cwd=root)
        if result.returncode:return result.returncode
        return subprocess.run(['xcrun','devicectl','device','process','launch','--device',args.device,bundle,'--timeout','30'],cwd=root).returncode
    return 0
if __name__=='__main__':sys.exit(main())
