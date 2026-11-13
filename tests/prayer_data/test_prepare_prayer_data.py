import importlib.util
import json
from pathlib import Path
import unittest
from datetime import date,timedelta

ROOT=Path(__file__).resolve().parents[2]
spec=importlib.util.spec_from_file_location('prepare_prayer_data',ROOT/'scripts/prepare_prayer_data.py')
module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)

class PrayerDataTests(unittest.TestCase):
 def rows(self,year=2026):
  return [{'date':(date(year,1,1)+timedelta(days=i)).isoformat(),'times':dict(zip(module.KEYS,['06:00','07:30','12:30','15:30','18:00','19:30']))} for i in range((date(year+1,1,1)-date(year,1,1)).days)]
 def test_complete_and_leap_year(self):
  self.assertEqual(len(module.validate_rows(self.rows(),2026)),365)
  self.assertEqual(len(module.validate_rows(self.rows(2028),2028)),366)
 def test_missing_and_duplicate_day(self):
  rows=self.rows()
  with self.assertRaises(ValueError):module.validate_rows(rows[:-1],2026)
  rows[1]['date']=rows[0]['date']
  with self.assertRaises(ValueError):module.validate_rows(rows,2026)
 def test_invalid_and_unordered_time(self):
  for value in ['24:00','6:00','20:30']:
   rows=self.rows();rows[0]['times']['imsak']=value
   with self.assertRaises(ValueError):module.validate_rows(rows,2026)
 def test_bundled_catalog_has_one_full_year_per_region(self):
  base=ROOT/'assets/prayer_times';catalog=json.loads((base/'regions.json').read_text())
  self.assertEqual(len(catalog['regions']),880)
  for region in catalog['regions']:
   payload=json.loads((base/'v1/2026'/f'{region["id"]}.json').read_text())
   self.assertEqual(payload['region'],region['id']);self.assertEqual(len(payload['days']),365)
if __name__=='__main__':unittest.main()
