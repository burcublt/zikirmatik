import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zikirmatik/app/theme/app_colors.dart';
import 'package:zikirmatik/core/localization/app_localizations_x.dart';
import 'package:zikirmatik/l10n/app_localizations.dart';
import 'package:zikirmatik/features/prayer_times/application/prayer_notifier.dart';
import 'package:zikirmatik/features/prayer_times/domain/prayer_schedule.dart';

String prayerNameLabel(AppLocalizations l10n, PrayerName name) =>
    switch (name) {
      PrayerName.fajr => l10n.prayerFajr,
      PrayerName.sunrise => l10n.prayerSunrise,
      PrayerName.dhuhr => l10n.prayerDhuhr,
      PrayerName.asr => l10n.prayerAsr,
      PrayerName.maghrib => l10n.prayerMaghrib,
      PrayerName.isha => l10n.prayerIsha,
    };

class PrayerCard extends ConsumerWidget {
  const PrayerCard({super.key, required this.onTap, this.large = false});
  final VoidCallback onTap;
  final bool large;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(prayerNotifierProvider);
    final now = ref.watch(prayerClockProvider).asData?.value ?? DateTime.now();
    ref.listen(prayerClockProvider, (_, value) {
      final time = value.asData?.value;
      if (time != null) {
        ref.read(prayerNotifierProvider.notifier).ensureCoverage(time);
      }
    });
    final data = state.asData?.value;
    final next = data?.schedule?.nextPrayer(now);
    final ready = next != null && data!.schedule!.dayAt(now) != null;
    return Semantics(
      button: true,
      label: ready
          ? '${l10n.prayerTimes}, ${l10n.nextPrayer}: ${prayerNameLabel(l10n, next.name)}'
          : l10n.prayerTimes,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(17),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(17),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF365D35),
                  AppColors.surfaceGreen,
                  AppColors.deepGreen,
                ],
              ),
              border: Border.all(
                color: AppColors.gold.withValues(alpha: 0.9),
                width: 0.8,
              ),
            ),
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(4, 8, 14, 8),
              child: Row(
                children: [
                  ExcludeSemantics(
                    child: SizedBox(
                      width: large ? 91 : 72,
                      height: large ? 98 : 76,
                      child: CustomPaint(painter: _MosquePainter()),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: state.isLoading
                        ? Row(
                            children: [
                              const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.gold,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  l10n.prayerLoading,
                                  style: const TextStyle(
                                    color: AppColors.cream,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : ready
                        ? LayoutBuilder(
                            builder: (context, box) {
                              final compact =
                                  box.maxWidth < 235 ||
                                  MediaQuery.textScalerOf(context).scale(1) >
                                      1.2;
                              final name = Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    l10n.nextPrayer,
                                    style: const TextStyle(
                                      color: AppColors.softGold,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    prayerNameLabel(l10n, next.name),
                                    style: TextStyle(
                                      color: AppColors.cream,
                                      fontFamily: 'NotoSerif',
                                      fontSize: large ? 24 : 21,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              );
                              final countdown = Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: compact
                                    ? CrossAxisAlignment.start
                                    : CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    prayerCountdown(next.at.difference(now)),
                                    key: const ValueKey('prayer-countdown'),
                                    style: TextStyle(
                                      color: AppColors.cream,
                                      fontSize: large ? 24 : 19,
                                      fontWeight: FontWeight.w600,
                                      fontFeatures: const [
                                        FontFeature.tabularFigures(),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    l10n.timeRemaining,
                                    style: const TextStyle(
                                      color: AppColors.cream,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              );
                              // The remaining-time label intentionally has no chevron or arrow.
                              if (compact) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    name,
                                    const SizedBox(height: 5),
                                    countdown,
                                  ],
                                );
                              }
                              return Row(
                                children: [
                                  Expanded(child: name),
                                  const SizedBox(width: 8),
                                  countdown,
                                ],
                              );
                            },
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                l10n.prayerTimes,
                                style: const TextStyle(
                                  color: AppColors.softGold,
                                  fontFamily: 'NotoSerif',
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                data?.status == PrayerStatus.needsLocation
                                    ? l10n.prayerUseLocation
                                    : l10n.prayerChooseLocation,
                                style: const TextStyle(
                                  color: AppColors.cream,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MosquePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min(size.width / 80, size.height / 90);
    canvas.save();
    canvas.translate(
      (size.width - 80 * scale) / 2,
      (size.height - 90 * scale) / 2,
    );
    canvas.scale(scale);
    final gold = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFFEDAE), Color(0xFFD8A344), Color(0xFF927029)],
      ).createShader(const Rect.fromLTWH(0, 0, 80, 90));
    canvas.drawCircle(
      const Offset(40, 40),
      34,
      Paint()
        ..shader = RadialGradient(
          colors: [AppColors.gold.withValues(alpha: 0.18), Colors.transparent],
        ).createShader(const Rect.fromLTWH(2, 2, 76, 76)),
    );
    void dome(double x, double y, double width, double height) {
      final path = Path()
        ..moveTo(x, y + height)
        ..lineTo(x, y + height * 0.45)
        ..quadraticBezierTo(x, y + height * 0.2, x + width / 2, y)
        ..quadraticBezierTo(
          x + width,
          y + height * 0.2,
          x + width,
          y + height * 0.45,
        )
        ..lineTo(x + width, y + height)
        ..close();
      canvas.drawPath(path, gold);
    }

    dome(24, 26, 35, 53);
    dome(10, 54, 22, 25);
    dome(52, 55, 23, 24);
    for (final (x, height) in [(12.0, 58.0), (67.0, 49.0)]) {
      canvas.drawRect(Rect.fromLTWH(x, 79 - height, 4, height), gold);
      canvas.drawPath(
        Path()
          ..moveTo(x - 2, 79 - height)
          ..lineTo(x + 2, 70 - height)
          ..lineTo(x + 6, 79 - height)
          ..close(),
        gold,
      );
      canvas.drawLine(
        Offset(x + 2, 70 - height),
        Offset(x + 2, 65 - height),
        Paint()
          ..color = AppColors.softGold
          ..strokeWidth = 0.8,
      );
    }
    canvas.drawLine(
      const Offset(41.5, 16),
      const Offset(41.5, 28),
      Paint()
        ..color = AppColors.softGold
        ..strokeWidth = 1,
    );
    canvas.drawArc(
      const Rect.fromLTWH(39, 12, 6, 6),
      0.7,
      4,
      false,
      Paint()
        ..color = AppColors.softGold
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke,
    );
    final dark = Paint()..color = AppColors.deepGreen;
    for (final x in [30.0, 40.0, 50.0]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, 55, 4, 12),
          const Radius.circular(2),
        ),
        dark,
      );
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(38, 69, 8, 15),
        const Radius.circular(4),
      ),
      dark,
    );
    canvas.drawRect(const Rect.fromLTWH(4, 79, 73, 3), gold);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_MosquePainter oldDelegate) => false;
}
