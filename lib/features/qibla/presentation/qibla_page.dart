import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:true_compass/true_compass.dart';
import 'package:zikirmatik/app/theme/app_palette.dart';
import 'package:zikirmatik/app/widgets/zikr_scaffold.dart';
import 'package:zikirmatik/core/localization/app_localizations_x.dart';
import 'package:zikirmatik/features/home/presentation/widgets/main_bottom_nav.dart';
import 'package:zikirmatik/features/prayer_times/data/prayer_location_service.dart';
import 'package:zikirmatik/features/prayer_times/presentation/prayer_times_page.dart';
import 'package:zikirmatik/features/qibla/application/qibla_providers.dart';
import 'package:zikirmatik/features/qibla/domain/qibla_direction.dart';

class QiblaPage extends ConsumerStatefulWidget {
  const QiblaPage({super.key, required this.onNavTap});
  final ValueChanged<int> onNavTap;
  @override
  ConsumerState<QiblaPage> createState() => _QiblaPageState();
}

class _QiblaPageState extends ConsumerState<QiblaPage>
    with WidgetsBindingObserver {
  bool _active = true;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() => _active = state == AppLifecycleState.resumed);
  }

  void _chooseCity() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const PrayerTimesPage()));
    if (mounted) ref.invalidate(qiblaLocationProvider);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final location = ref.watch(qiblaLocationProvider);
    return ZikrScaffold(
      appBar: AppBar(centerTitle: true, title: Text(l.qibla)),
      bottomNavigationBar: MainBottomNav(
        currentIndex: 2,
        onTap: widget.onNavTap,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            location.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, stack) {
                final issue = error is PrayerLocationException
                    ? error.issue
                    : null;
                final message = switch (issue) {
                  PrayerLocationIssue.permissionNeeded =>
                    l.prayerLocationExplanation,
                  PrayerLocationIssue.denied ||
                  PrayerLocationIssue.deniedForever => l.prayerPermissionDenied,
                  PrayerLocationIssue.servicesDisabled =>
                    l.prayerLocationDisabled,
                  _ => l.prayerUnavailable,
                };
                return Column(
                  children: [
                    Icon(
                      Icons.location_off_outlined,
                      size: 52,
                      color: context.palette.gold,
                    ),
                    const SizedBox(height: 16),
                    Text(message, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => ref
                          .read(qiblaLocationProvider.notifier)
                          .useLocation(),
                      child: Text(l.prayerUseLocation),
                    ),
                    TextButton(
                      onPressed: _chooseCity,
                      child: Text(l.prayerChooseCity),
                    ),
                    if (issue == PrayerLocationIssue.deniedForever)
                      TextButton(
                        onPressed: Geolocator.openAppSettings,
                        child: Text(l.prayerOpenSettings),
                      ),
                    if (issue == PrayerLocationIssue.servicesDisabled)
                      TextButton(
                        onPressed: Geolocator.openLocationSettings,
                        child: Text(l.prayerOpenSettings),
                      ),
                  ],
                );
              },
              data: (value) {
                final place = value.location;
                final bearing = qiblaBearing(place.latitude, place.longitude);
                final sensor = _active && bearing != null
                    ? ref.watch(qiblaHeadingProvider(place))
                    : const AsyncValue<CompassHeading>.loading();
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextButton.icon(
                            onPressed: _chooseCity,
                            icon: const Icon(Icons.location_on_outlined),
                            label: Text(
                              place.label.isEmpty
                                  ? l.prayerCurrentLocation
                                  : place.label,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: l.prayerUseLocation,
                          onPressed: () => ref
                              .read(qiblaLocationProvider.notifier)
                              .useLocation(),
                          icon: const Icon(Icons.my_location),
                        ),
                      ],
                    ),
                    if (value.saved)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          l.prayerSavedLocation,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    Text(
                      l.qiblaDirection,
                      style: TextStyle(
                        color: context.palette.gold,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (bearing != null)
                      Text(
                        '${bearing.round()}°',
                        textDirection: TextDirection.ltr,
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    const SizedBox(height: 20),
                    if (bearing == null)
                      Text(l.qiblaUndefined, textAlign: TextAlign.center)
                    else
                      sensor.when(
                        skipLoadingOnRefresh: false,
                        loading: () => SizedBox(
                          height: 260,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const CircularProgressIndicator(),
                                const SizedBox(height: 16),
                                Text(l.qiblaWaiting),
                              ],
                            ),
                          ),
                        ),
                        error: (e, s) => Column(
                          children: [
                            Icon(
                              Icons.explore_off_outlined,
                              size: 100,
                              color: context.palette.gold,
                            ),
                            const SizedBox(height: 20),
                            Text(l.qiblaNoSensor, textAlign: TextAlign.center),
                            TextButton(
                              onPressed: () =>
                                  ref.invalidate(qiblaHeadingProvider(place)),
                              child: Text(l.retry),
                            ),
                          ],
                        ),
                        data: (heading) {
                          final turn = qiblaTurn(bearing, heading.trueHeading!);
                          final calibrated =
                              heading.accuracy == CompassAccuracy.high &&
                              !heading.needsCalibration;
                          final aligned = calibrated && turn.abs() <= 5;
                          final hint = !calibrated
                              ? l.qiblaCalibrate
                              : aligned
                              ? l.qiblaAligned
                              : turn < 0
                              ? l.qiblaTurnLeft(turn.abs().round())
                              : l.qiblaTurnRight(turn.abs().round());
                          return Column(
                            children: [
                              LayoutBuilder(
                                builder: (context, c) => Center(
                                  child: SizedBox.square(
                                    dimension: math.min(c.maxWidth, 340),
                                    child: Semantics(
                                      label:
                                          '${l.qiblaDirection} ${bearing.round()}°. $hint',
                                      child: CustomPaint(
                                        painter: QiblaDialPainter(
                                          heading: heading.trueHeading!,
                                          turn: turn,
                                          gold: context.palette.gold,
                                          northLabel: l.qiblaNorthInitial,
                                          eastLabel: l.qiblaEastInitial,
                                          southLabel: l.qiblaSouthInitial,
                                          westLabel: l.qiblaWestInitial,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: context.palette.surfaceGreen,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: context.palette.gold,
                                  ),
                                ),
                                child: Text(
                                  hint,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: context.palette.softGold,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    const SizedBox(height: 20),
                    Text(l.qiblaInstructions, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    Text(
                      l.qiblaTrueNorth,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class QiblaDialPainter extends CustomPainter {
  QiblaDialPainter({
    required this.heading,
    required this.turn,
    required this.gold,
    required this.northLabel,
    required this.eastLabel,
    required this.southLabel,
    required this.westLabel,
  });
  final double heading, turn;
  final Color gold;
  final String northLabel, eastLabel, southLabel, westLabel;
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero), radius = size.width / 2 - 8;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [const Color(0xFF346448), const Color(0xFF00251B)],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
    final line = Paint()
      ..color = gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, line);
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-heading * math.pi / 180);
    for (var i = 0; i < 72; i++) {
      final angle = i * math.pi / 36 - math.pi / 2;
      final length = i % 6 == 0 ? 13.0 : 6.0;
      canvas.drawLine(
        Offset(math.cos(angle), math.sin(angle)) * (radius - 4),
        Offset(math.cos(angle), math.sin(angle)) * (radius - 4 - length),
        line..strokeWidth = i % 6 == 0 ? 2 : 1,
      );
    }
    for (final entry in [
      (0.0, northLabel),
      (90.0, eastLabel),
      (180.0, southLabel),
      (270.0, westLabel),
    ]) {
      final angle = entry.$1 * math.pi / 180 - math.pi / 2;
      final point = Offset(math.cos(angle), math.sin(angle)) * (radius - 32);
      canvas.save();
      canvas.translate(point.dx, point.dy);
      canvas.rotate(heading * math.pi / 180);
      final text = TextPainter(
        text: TextSpan(
          text: entry.$2,
          style: TextStyle(
            fontFamily: 'NotoSerif',
            color: gold,
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      text.paint(canvas, Offset(-text.width / 2, -text.height / 2));
      canvas.restore();
    }
    canvas.restore();
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(turn * math.pi / 180);
    canvas.drawPath(
      Path()
        ..moveTo(0, -radius + 46)
        ..lineTo(-18, -radius + 92)
        ..lineTo(0, -radius + 82)
        ..lineTo(18, -radius + 92)
        ..close(),
      Paint()..color = gold,
    );
    canvas.restore();
    final box = Rect.fromCenter(center: center, width: 65, height: 60);
    canvas.drawRRect(
      RRect.fromRectAndRadius(box, const Radius.circular(5)),
      Paint()..color = const Color(0xFF101D17),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(box, const Radius.circular(5)),
      line..strokeWidth = 1.5,
    );
    canvas.drawRect(
      Rect.fromLTWH(box.left, box.top + 14, box.width, 9),
      Paint()..color = gold,
    );
    canvas.drawRect(
      Rect.fromLTWH(center.dx + 5, center.dy + 4, 13, 24),
      Paint()..color = gold,
    );
  }

  @override
  bool shouldRepaint(QiblaDialPainter old) =>
      old.heading != heading ||
      old.turn != turn ||
      old.gold != gold ||
      old.northLabel != northLabel ||
      old.eastLabel != eastLabel ||
      old.southLabel != southLabel ||
      old.westLabel != westLabel;
}
