import 'dart:math' as math;

/// Initial great-circle bearing to the Kaaba, clockwise from true north.
double? qiblaBearing(double latitude, double longitude) {
  if (!latitude.isFinite ||
      !longitude.isFinite ||
      latitude.abs() > 90 ||
      longitude.abs() > 180) {
    return null;
  }
  const kaabaLat = 21.422487, kaabaLon = 39.826206;
  final lat = latitude * math.pi / 180;
  final target = kaabaLat * math.pi / 180;
  final delta = (kaabaLon - longitude) * math.pi / 180;
  final y = math.sin(delta) * math.cos(target);
  final x =
      math.cos(lat) * math.sin(target) -
      math.sin(lat) * math.cos(target) * math.cos(delta);
  // The bearing is undefined at the destination or its antipode.
  if (x.abs() < 1e-10 && y.abs() < 1e-10) return null;
  return normalizeDegrees(math.atan2(y, x) * 180 / math.pi);
}

double normalizeDegrees(double angle) => (angle % 360 + 360) % 360;
double qiblaTurn(double bearing, double heading) =>
    normalizeDegrees(bearing - heading + 180) - 180;
