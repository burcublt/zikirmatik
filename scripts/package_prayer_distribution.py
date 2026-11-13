#!/usr/bin/env python3
"""Create a verified static-hosting ZIP. Does not upload or publish."""
import argparse
import hashlib
import json
from pathlib import Path
from zipfile import ZipFile, ZIP_DEFLATED

ROOT=Path(__file__).resolve().parents[1]
def package(output):
    source=ROOT/'assets/prayer_times';manifest=json.loads((source/'manifest.json').read_text())
    files=manifest['files']
    for name,digest in files.items():
        path=source/name
        if not path.resolve().is_relative_to(source.resolve()):raise ValueError('Invalid manifest path')
        if hashlib.sha256(path.read_bytes()).hexdigest()!=digest:raise ValueError(f'Checksum mismatch: {name}')
    output=Path(output);output.parent.mkdir(parents=True,exist_ok=True)
    with ZipFile(output,'w',ZIP_DEFLATED,compresslevel=9) as archive:
        for name in sorted(files):archive.write(source/name,name)
        archive.write(source/'manifest.json','manifest.json')
    print(f'Prepared {len(files)} verified files: {output} ({output.stat().st_size} bytes)')
if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--output',default=str(ROOT/'build/prayer-data-2026.zip'))
    try:package(parser.parse_args().output)
    except (ValueError,KeyError,OSError) as e:parser.exit(2,str(e)+'\n')
