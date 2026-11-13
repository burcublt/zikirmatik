import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zikirmatik/app/app.dart';

void main() {
  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks([
      'Noto Serif',
    ], await rootBundle.loadString('assets/fonts/OFL.txt'));
  });
  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks([
      'İmsakiyem annual timetable dataset',
    ], await rootBundle.loadString('assets/prayer_times/SOURCE-LICENSE.txt'));
  });
  runApp(const ProviderScope(child: ZikirmatikApp()));
}
