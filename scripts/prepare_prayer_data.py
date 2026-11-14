#!/usr/bin/env python3
"""Validate an Im­sakiyem annual export and build app/CDN district files.

No downloads, uploads or deployment. This tool does not infer missing days/times.
"""
import argparse
from collections import defaultdict
from datetime import date, timedelta, datetime, timezone
import hashlib
import json
from pathlib import Path
import re

KEYS = ('imsak','gunes','ogle','ikindi','aksam','yatsi')
SOURCE_URL = 'https://github.com/karademirmustafa/ezanvakti-imsakiyem-api'

def compact(value):
    return (json.dumps(value, ensure_ascii=False, separators=(',', ':'))+'\n').encode()

def validate_rows(rows, year):
    expected = (date(year+1,1,1)-date(year,1,1)).days
    if len(rows) != expected:
        raise ValueError(f'Incomplete calendar: {len(rows)}/{expected}')
    result=[]
    for index,row in enumerate(sorted(rows,key=lambda r:r['date'])):
        day=(date(year,1,1)+timedelta(days=index)).isoformat()
        if row['date'][:10] != day:
            raise ValueError(f'Missing or duplicate date: {day}')
        times=[row['times'][key] for key in KEYS]
        if not all(isinstance(t,str) and re.fullmatch(r'([01]\d|2[0-3]):[0-5]\d',t) for t in times):
            raise ValueError(f'Invalid clock time: {day}')
        if any(a>=b for a,b in zip(times,times[1:])):
            raise ValueError(f'Unordered prayer times: {day}')
        result.append([day,*times])
    return result

def merge_base(base, incoming, year):
    if base is None:return {}, {}, []
    base=Path(base);manifest=json.loads((base/'manifest.json').read_text())
    if manifest.get('version')!=1:raise ValueError('Unsupported base manifest')
    files={}
    for name,digest in manifest['files'].items():
        path=base/name
        if not path.resolve().is_relative_to(base.resolve()):raise ValueError('Unsafe base manifest path')
        data=path.read_bytes()
        if hashlib.sha256(data).hexdigest()!=digest:raise ValueError(f'Base checksum mismatch: {name}')
        files[name]=data
    old={r['id']:r for r in json.loads(files['regions.json'])['regions']}
    new={r['id']:r for r in json.loads(incoming['regions.json'])['regions']}
    if old!=new:raise ValueError('Year catalogs differ; explicit region migration required')
    previous=manifest.get('upstreams',{})
    if not previous:
        previous={str(y):{'sha256':manifest['upstreamSha256'],'source':manifest['source']} for y in manifest['years']}
    return files,dict(previous),list(manifest['years'])

def prepare(source, districts, states, license_path, output, base=None):
    raw=Path(source).read_bytes(); dataset=json.loads(raw);year=dataset['meta']['year']
    if type(year) is not int or not 2000<=year<=2100: raise ValueError('Invalid year')
    districts=json.loads(Path(districts).read_text());states={s['_id']:s for s in json.loads(Path(states).read_text())}
    refs={r['_id']:r for r in districts}
    if len(refs)!=len(districts): raise ValueError('Duplicate region IDs')
    grouped=defaultdict(list)
    for row in dataset['data']:
        key=str(row['district_id'])
        if key not in refs: raise ValueError(f'Unknown region {key}')
        grouped[key].append(row)
    if set(grouped)!=set(refs):raise ValueError('Region catalog and calendar coverage differ')
    if dataset['meta']['total_records']!=len(dataset['data']) or dataset['meta']['total_districts']!=len(grouped):raise ValueError('Incorrect export counts')
    files={};regions=[]
    # Validate everything before writing any distributable file.
    for key,rows in grouped.items():
        ref=refs[key];state=states[ref['state_id']]
        if state['country_id']!=ref['country_id']:raise ValueError('Wrong region hierarchy')
        country={'2':'TR','1':'CY'}.get(ref['country_id'])
        if country is None:raise ValueError('Country timezone not configured')
        zone='Europe/Istanbul' if country=='TR' else 'Asia/Nicosia'
        regions.append({'id':key,'name':ref['name'],'province':state['name'],'country':country,'zone':zone})
        files[f'v1/{year}/{key}.json']=compact({'version':1,'year':year,'region':key,'zone':zone,'source':'diyanet-annual','days':validate_rows(rows,year)})
    files['regions.json']=compact({'version':1,'regions':sorted(regions,key=lambda r:(r['country'],r['province'],r['name']))})
    files['ATTRIBUTION.txt']=(f'Data: İmsakiyem annual export; upstream declares Diyanet İşleri Başkanlığı as source.\n{SOURCE_URL}\nYear: {year}\nOriginal generated_at: {dataset["meta"].get("generated_at", "unknown")}\nThis is not a Diyanet-operated distribution service.\nUpstream project license is preserved in SOURCE-LICENSE.txt.\n').encode()
    files['SOURCE-LICENSE.txt']=Path(license_path).read_bytes()
    previous,upstreams,years=merge_base(base,files,year)
    previous.update(files);files=previous;years=sorted(set(years+[year]))
    upstreams[str(year)]={'sha256':hashlib.sha256(raw).hexdigest(),'source':dataset['meta'].get('source',SOURCE_URL),'generatedAt':dataset['meta'].get('generated_at'),'timezoneCrossChecks':dataset['meta'].get('timezoneCrossChecks',{})}
    files['ATTRIBUTION.txt']=(f'Data: İmsakiyem published annual data; upstream declares Diyanet İşleri Başkanlığı as source.\n{SOURCE_URL}\nYears: {", ".join(map(str,years))}\nSee manifest.json upstreams for per-year provenance.\nThis is not a Diyanet-operated distribution service.\nUpstream project license is preserved in SOURCE-LICENSE.txt.\n').encode()
    manifest={'version':1,'years':years,'regionCount':len(regions),'source':SOURCE_URL,'upstreamSha256':hashlib.sha256(raw).hexdigest(),'upstreams':upstreams,'generatedAt':datetime.now(timezone.utc).isoformat(),'files':{name:hashlib.sha256(data).hexdigest() for name,data in files.items()}}
    files['manifest.json']=compact(manifest)
    output=Path(output)
    # The output directory must be new, preventing stale district/year remnants.
    if output.exists():raise ValueError('Choose a new output directory')
    for name,data in files.items():
        target=output/name;target.parent.mkdir(parents=True,exist_ok=True);target.write_bytes(data)
    print(json.dumps({'year':year,'regions':len(regions),'days':len(dataset['data']),'bytes':sum(map(len,files.values())),'sha256':manifest['upstreamSha256']},ensure_ascii=False))
    return manifest

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    for key in ('source','districts','states','license','output'):parser.add_argument('--'+key,required=True)
    parser.add_argument('--merge-from',type=Path,help='Verified existing dataset to preserve alongside the new year')
    args=parser.parse_args()
    try:prepare(args.source,args.districts,args.states,args.license,args.output,base=args.merge_from)
    except (ValueError,KeyError,TypeError) as error:parser.exit(2,f'Invalid prayer data: {error}\n')
if __name__=='__main__':main()
