#!/usr/bin/env python3
"""Fetch a complete published annual dataset at the documented provider rate.

Uses the public, documented İmsakiyem v2 endpoint. Does not compute prayer times.
A resumable cache is local only; no export is produced until every region passes.
"""
import argparse
from datetime import datetime, timezone, timedelta
import hashlib
import json
from pathlib import Path
import subprocess
import time
from urllib.parse import urlencode
from zoneinfo import ZoneInfo, ZoneInfoNotFoundError
from prepare_prayer_data import validate_rows, KEYS

PROVIDER='https://ezanvakti.imsakiyem.com'

def normalize_calendar(payload,region,year,reference=None):
    if payload.get('success') is not True:raise ValueError('Provider returned failure')
    data=payload['data'];location=data['location']
    if str(location['district_id'])!=region['id']:raise ValueError('Wrong region in provider response')
    if location['country']['iso2']!=region['country']:raise ValueError('Wrong country in provider response')
    if data['source']['type']!='diyanet':raise ValueError('Expected published Diyanet data')
    zone_mismatch=False
    if 'zone' in region:
        try:actual_zone=ZoneInfo(location['timezone']);expected_zone=ZoneInfo(region['zone'])
        except (KeyError,TypeError,ZoneInfoNotFoundError) as error:raise ValueError('Missing or invalid source timezone') from error
        for index in range((datetime(year+1,1,1)-datetime(year,1,1)).days):
            instant=datetime(year,1,1,12,tzinfo=timezone.utc)+timedelta(days=index)
            if instant.astimezone(actual_zone).utcoffset()!=instant.astimezone(expected_zone).utcoffset():zone_mismatch=True;break
    rows=[{'date':r['date'],'district_id':region['id'],'times':{key:r[key] for key in KEYS},'meta':{'source':'Diyanet İşleri Başkanlığı'}} for r in data['times']]
    clocks=validate_rows(rows,year)
    if zone_mismatch:
        if reference is None:raise ValueError('Source timezone differs from catalog; v1 cross-check required')
        if reference.get('success') is not True:raise ValueError('Invalid timezone cross-check response')
        for row in reference['data']:
            district=row['district_id']
            if str(district['_id'])!=region['id'] or str(district['country_id']['_id'])!={'TR':'2','CY':'1'}[region['country']]:raise ValueError('Wrong timezone cross-check region')
            if row.get('meta',{}).get('source')!='Diyanet İşleri Başkanlığı':raise ValueError('Wrong timezone cross-check source')
        if validate_rows(reference['data'],year)!=clocks:raise ValueError('Timezone cross-check clocks differ')
    return rows

def parse_headers(text):
    result={}
    for line in text.splitlines():
        if ':' in line:
            key,value=line.split(':',1);result[key.lower().strip()]=value.strip()
    return result

class Downloader:
    def __init__(self,interval=3.2):
        if interval<3.1:raise ValueError('Minimum interval is 3.1 seconds (100 requests / 5 minutes)')
        self.interval=interval;self.next_at=0
    def verified_rows(self,payload,region,year,cache):
        try:return normalize_calendar(payload,region,year)
        except ValueError as error:
            if 'v1 cross-check required' not in str(error):raise
        path=cache/str(year)/(region['id']+'.v1-reference.json')
        if not path.exists():
            time.sleep(max(0,self.next_at-time.monotonic()));self.next_at=time.monotonic()+self.interval
            url=PROVIDER+f'/api/prayer-times/{region["id"]}/yearly?startDate={year}-01-01&limit=366'
            result=subprocess.run(['/usr/bin/curl','--silent','--show-error','--location','--compressed','--max-time','40','--max-filesize','2097152',url],capture_output=True,text=True)
            if result.returncode:raise ValueError('Timezone cross-check download failed; rerun to resume')
            reference=json.loads(result.stdout)
            normalize_calendar(payload,region,year,reference)
            path.write_text(result.stdout)
        reference=json.loads(path.read_text())
        return normalize_calendar(payload,region,year,reference)
    def fetch(self,region,year,cache):
        destination=cache/str(year)/(region['id']+'.json')
        if destination.exists():
            payload=json.loads(destination.read_text());self.verified_rows(payload,region,year,cache);return payload
        destination.parent.mkdir(parents=True,exist_ok=True)
        partial=destination.with_suffix('.part');headers=destination.with_suffix('.headers')
        url=PROVIDER+'/api/v2/times?'+urlencode({'district':region['id'],'date':f'{year}-01-01','period':'yearly'})
        for attempt in range(4):
            time.sleep(max(0,self.next_at-time.monotonic()));self.next_at=time.monotonic()+self.interval
            request=subprocess.run(['/usr/bin/curl','--silent','--show-error','--location','--compressed','--max-time','40','--max-filesize','2097152','--dump-header',str(headers),url,'--output',str(partial),'--write-out','%{http_code}'],capture_output=True,text=True)
            status=request.stdout.strip();h=parse_headers(headers.read_text() if headers.exists() else '')
            if status=='429':
                wait=max(300,int(h.get('retry-after','300')));print(f'Provider rate limit; respecting Retry-After {wait}s',flush=True);self.next_at=time.monotonic()+wait;continue
            if request.returncode or status!='200':
                print(f'Region {region["id"]} attempt {attempt+1}: HTTP {status or "none"}, curl {request.returncode}: {request.stderr.strip()[:200]}',flush=True)
                if status in ('404','400'):raise ValueError(f'No published {year} calendar for {region["id"]}: HTTP {status}')
                self.next_at=max(self.next_at,time.monotonic()+min(60,5*(attempt+1)));continue
            payload=json.loads(partial.read_text());self.verified_rows(payload,region,year,cache)
            partial.replace(destination)
            if h.get('ratelimit-remaining')=='0':self.next_at=max(self.next_at,time.monotonic()+int(h.get('ratelimit-reset','300'))+1)
            return payload
        raise ValueError(f'Provider unavailable for {region["id"]}; rerun to resume from cache')

def main(argv=None):
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--year',required=True,type=int);parser.add_argument('--catalog',required=True,type=Path)
    parser.add_argument('--cache',required=True,type=Path);parser.add_argument('--output',required=True,type=Path)
    args=parser.parse_args(argv)
    if not 2000<=args.year<=2100:parser.error('Invalid year')
    catalog=json.loads(args.catalog.read_text());regions=catalog['regions']
    if len({r['id'] for r in regions})!=len(regions):parser.error('Duplicate region IDs')
    rows=[];digests={};downloader=Downloader();started=time.monotonic()
    try:
        for index,region in enumerate(regions,1):
            payload=downloader.fetch(region,args.year,args.cache)
            rows.extend(downloader.verified_rows(payload,region,args.year,args.cache))
            path=args.cache/str(args.year)/(region['id']+'.json');digests[region['id']]=hashlib.sha256(path.read_bytes()).hexdigest()
            if index%10==0 or index==1 or index==len(regions):print(f'{index}/{len(regions)} complete; elapsed {int(time.monotonic()-started)}s; {region["id"]} {region["province"]} / {region["name"]}',flush=True)
        audits={p.name.split('.')[0]:{'sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'expectedZone':next(r['zone'] for r in regions if r['id']==p.name.split('.')[0]),'reportedZone':json.loads((p.parent/(p.name.split('.')[0]+'.json')).read_text())['data']['location']['timezone']} for p in (args.cache/str(args.year)).glob('*.v1-reference.json')}
        export={'meta':{'year':args.year,'total_districts':len(regions),'total_records':len(rows),'generated_at':datetime.now(timezone.utc).isoformat(),'source':PROVIDER+'/api/v2/times','responseSha256':digests,'timezoneCrossChecks':audits},'data':rows}
        args.output.parent.mkdir(parents=True,exist_ok=True);temporary=args.output.with_suffix('.tmp');temporary.write_text(json.dumps(export,ensure_ascii=False,separators=(',',':'))+'\n');temporary.replace(args.output)
        print(f'COMPLETE: {len(regions)} regions, {len(rows)} days, {args.output}',flush=True)
    except (ValueError,KeyError,OSError) as error:parser.exit(2,f'Export not written: {error}\nCached valid regions are preserved.\n')
if __name__=='__main__':main()
