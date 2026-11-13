#!/usr/bin/env python3
"""Xcode Release gate; validates only identifiers, never prints config values."""
import base64
import os
import sys
from build_release import validate

def validate_environment(environment):
    values = {}
    try:
        for encoded in environment.get('DART_DEFINES', '').split(','):
            if not encoded:
                continue
            item = base64.b64decode(encoded, validate=True).decode('utf-8')
            key, value = item.split('=', 1)
            values[key] = value
    except (ValueError, UnicodeError):
        return ['DART_DEFINES okunamadı. scripts/build_release.py kullanın.']
    errors = validate('ios', values)
    if values.get('IOS_BUNDLE_ID') != environment.get('PRODUCT_BUNDLE_IDENTIFIER'):
        errors.append('Xcode Bundle ID ile yayın dosyası eşleşmiyor.')
    if values.get('ADMOB_IOS_APP_ID') != environment.get('ADMOB_IOS_APP_ID'):
        errors.append('Xcode AdMob App ID ile yayın dosyası eşleşmiyor.')
    return errors

if __name__ == '__main__':
    errors = validate_environment(os.environ)
    for error in errors:
        print('error: ' + error, file=sys.stderr)
    sys.exit(2 if errors else 0)
