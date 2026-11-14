import contextlib
from datetime import date,timedelta
import hashlib
import importlib.util
import io
import json
from pathlib import Path
import sys
import tempfile
import unittest
import zipfile
from unittest.mock import patch

ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'scripts'))
import prepare_prayer_data as prepare
import fetch_prayer_year as fetch
import package_prayer_distribution as distribution

class PrayerYearImportTests(unittest.TestCase):
 def setUp(self):
  self.temp=tempfile.TemporaryDirectory();self.addCleanup(self.temp.cleanup);self.root=Path(self.temp.name)
  self.districts=self.root/'districts.json';self.states=self.root/'states.json';self.license=self.root/'LICENSE'
  self.districts.write_text(json.dumps([{'_id':'9541','name':'İSTANBUL','state_id':'539','country_id':'2'}]));self.states.write_text(json.dumps([{'_id':'539','name':'İSTANBUL','country_id':'2'}]));self.license.write_text('Test license')
 def source(self,year):
  count=(date(year+1,1,1)-date(year,1,1)).days
  rows=[{'district_id':'9541','date':(date(year,1,1)+timedelta(days=i)).isoformat(),'times':dict(zip(prepare.KEYS,['06:00','07:30','12:30','15:30','18:00','19:30']))} for i in range(count)]
  path=self.root/f'{year}.json';path.write_text(json.dumps({'meta':{'year':year,'total_districts':1,'total_records':count},'data':rows}));return path
 def generate(self,year,output,base=None):
  with contextlib.redirect_stdout(io.StringIO()):return prepare.prepare(self.source(year),self.districts,self.states,self.license,output,base=base)
 def test_merge_preserves_prior_year_bytes_and_records_both_sources(self):
  old=self.root/'old';new=self.root/'merged';self.generate(2026,old);before=(old/'v1/2026/9541.json').read_bytes()
  manifest=self.generate(2027,new,base=old)
  self.assertEqual((new/'v1/2026/9541.json').read_bytes(),before);self.assertEqual(manifest['years'],[2026,2027]);self.assertEqual(set(manifest['upstreams']),{'2026','2027'})
  self.assertEqual(len(json.loads((new/'v1/2027/9541.json').read_text())['days']),365)
 def test_distribution_name_and_contents_include_both_years(self):
  old=self.root/'old';self.generate(2026,old)
  merged=self.root/'assets/prayer_times';self.generate(2027,merged,base=old)
  with patch.object(distribution,'ROOT',self.root),contextlib.redirect_stdout(io.StringIO()):distribution.package()
  with zipfile.ZipFile(self.root/'build/prayer-data-2026-2027.zip') as archive:
   self.assertIsNone(archive.testzip());self.assertIn('v1/2026/9541.json',archive.namelist());self.assertIn('v1/2027/9541.json',archive.namelist())
   self.assertEqual(json.loads(archive.read('manifest.json'))['years'],[2026,2027])
 def test_corrupted_base_dataset_is_not_merged(self):
  old=self.root/'old';self.generate(2026,old);(old/'v1/2026/9541.json').write_text('{}')
  with self.assertRaisesRegex(ValueError,'checksum'):self.generate(2027,self.root/'new',base=old)
  self.assertFalse((self.root/'new').exists())
 def test_wrong_year_or_partial_wire_response_is_rejected(self):
  region={'id':'9541','country':'TR'}
  rows=json.loads(self.source(2027).read_text())['data']
  payload={'success':True,'data':{'location':{'district_id':'9541','country':{'iso2':'TR'}},'source':{'type':'diyanet'},'times':[{'date':r['date'],**r['times']} for r in rows]}}
  self.assertEqual(len(fetch.normalize_calendar(payload,region,2027)),365)
  with self.assertRaises(ValueError):fetch.normalize_calendar(payload,region,2026)
  payload['data']['times'].pop()
  with self.assertRaises(ValueError):fetch.normalize_calendar(payload,region,2027)
 def test_wrong_region_and_calculated_source_are_rejected(self):
  region={'id':'9541','country':'TR'}
  payload={'success':True,'data':{'location':{'district_id':'9206','country':{'iso2':'TR'}},'source':{'type':'diyanet'},'times':[]}}
  with self.assertRaisesRegex(ValueError,'region'):fetch.normalize_calendar(payload,region,2027)
  payload['data']['location']['district_id']='9541';payload['data']['source']['type']='calculated'
  with self.assertRaisesRegex(ValueError,'published'):fetch.normalize_calendar(payload,region,2027)
 def test_timezone_mismatch_is_rejected_before_export(self):
  region={'id':'9541','country':'TR','zone':'Europe/Istanbul'}
  payload={'success':True,'data':{'location':{'district_id':'9541','country':{'iso2':'TR'},'timezone':'America/New_York'},'source':{'type':'diyanet'},'times':[{'date':r['date'],**r['times']} for r in json.loads(self.source(2027).read_text())['data']]}}
  with self.assertRaisesRegex(ValueError,'timezone differs'):fetch.normalize_calendar(payload,region,2027)
 def test_timezone_metadata_override_requires_identical_full_year_reference(self):
  region={'id':'9541','country':'TR','zone':'Europe/Istanbul'}
  rows=json.loads(self.source(2027).read_text())['data']
  payload={'success':True,'data':{'location':{'district_id':'9541','country':{'iso2':'TR'},'timezone':'Asia/Tbilisi'},'source':{'type':'diyanet'},'times':[{'date':r['date'],**r['times']} for r in rows]}}
  reference={'success':True,'data':[{**r,'district_id':{'_id':'9541','country_id':{'_id':'2'}},'meta':{'source':'Diyanet İşleri Başkanlığı'}} for r in rows]}
  self.assertEqual(len(fetch.normalize_calendar(payload,region,2027,reference)),365)
  reference['data'][0]['times']['imsak']='06:01'
  with self.assertRaisesRegex(ValueError,'clocks differ'):fetch.normalize_calendar(payload,region,2027,reference)
 def test_fetcher_enforces_published_rate_limit(self):
  with self.assertRaises(ValueError):fetch.Downloader(interval=1)
if __name__=='__main__':unittest.main()
