import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zikirmatik/core/ads/admob.dart';

class _Consent extends AdsController {
  @override
  Future<AdsState> build() async => const AdsState(canRequest: true);
  void allow(bool value) => state = AsyncData(AdsState(canRequest: value));
}

enum _Result { success, failure, pending, exception }

class _Handle implements AdSlotHandle {
  _Handle(this.number, this.result, this.onLoaded, this.onFailed);
  final int number;
  final _Result result;
  final VoidCallback onLoaded;
  final void Function(Object) onFailed;
  int loads = 0, disposals = 0;
  @override
  double get height => 50;
  @override
  Future<void> load() async {
    loads++;
    switch (result) {
      case _Result.success:
        onLoaded();
      case _Result.failure:
        onFailed(StateError('offline'));
      case _Result.pending:
        break;
      case _Result.exception:
        throw StateError('channel unavailable');
    }
  }

  @override
  Widget buildView() => SizedBox(key: ValueKey('ad-$number'), height: 50);
  @override
  void dispose() {
    disposals++;
  }
}

class _Loader implements AdSlotLoader {
  _Loader(this.results, {this.pendingFirstPrepare = false});
  final List<_Result> results;
  final bool pendingFirstPrepare;
  final handles = <_Handle>[];
  final pending = Completer<AdSlotHandle?>();
  @override
  Future<AdSlotHandle?> prepare({
    required AdPlacement placement,
    required int width,
    required String adUnitId,
    required VoidCallback onLoaded,
    required void Function(Object) onFailed,
  }) async {
    final index = handles.length;
    final handle = _Handle(
      index,
      index < results.length ? results[index] : _Result.success,
      onLoaded,
      onFailed,
    );
    handles.add(handle);
    if (pendingFirstPrepare && index == 0) return pending.future;
    return handle;
  }
}

void main() {
  Future<ProviderContainer> mount(
    WidgetTester tester,
    _Loader loader, {
    AdPlacement placement = AdPlacement.zikrList,
    double width = 320,
  }) async {
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          adsControllerProvider.overrideWith(_Consent.new),
          adSlotLoaderProvider.overrideWithValue(loader),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: width,
                child: AdMobSlot(placement: placement),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    });
    return ProviderScope.containerOf(tester.element(find.byType(AdMobSlot)));
  }

  testWidgets(
    'native ve banner başarılı yüklemeden sonra kendiliğinden tekrar istenmez',
    (tester) async {
      for (final placement in AdPlacement.values) {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
        final loader = _Loader([_Result.success]);
        await mount(tester, loader, placement: placement);
        expect(find.byKey(const ValueKey('ad-0')), findsOneWidget);
        await tester.pump(const Duration(minutes: 3));
        expect(loader.handles.length, 1);
        expect(loader.handles.single.loads, 1);
      }
    },
  );
  testWidgets('başarısız alan kapanır ve 30 saniyeden önce yeniden istenmez', (
    tester,
  ) async {
    final loader = _Loader([_Result.failure, _Result.success]);
    await mount(tester, loader);
    expect(find.byKey(const ValueKey('ad-0')), findsNothing);
    expect(loader.handles.first.disposals, 1);
    await tester.pump(const Duration(seconds: 29));
    expect(loader.handles.length, 1);
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    expect(loader.handles.length, 2);
    expect(find.byKey(const ValueKey('ad-1')), findsOneWidget);
  });
  testWidgets(
    'yeniden deneme 30 60 120 saniye bekler ve üç denemeyle sınırlıdır',
    (tester) async {
      final loader = _Loader(List.filled(8, _Result.failure));
      await mount(tester, loader);
      for (final delay in [30, 60, 120]) {
        final before = loader.handles.length;
        await tester.pump(Duration(seconds: delay - 1));
        expect(loader.handles.length, before);
        await tester.pump(const Duration(seconds: 1));
        await tester.pump();
        expect(loader.handles.length, before + 1);
      }
      await tester.pump(const Duration(minutes: 20));
      expect(loader.handles.length, 4);
      expect(loader.handles.every((h) => h.disposals == 1), isTrue);
    },
  );
  testWidgets(
    'ekran kapanınca zamanlayıcı ve geç gelen hazırlık kaynağı temizlenir',
    (tester) async {
      final loader = _Loader([_Result.success], pendingFirstPrepare: true);
      await mount(tester, loader);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      loader.pending.complete(loader.handles.single);
      await tester.pump();
      expect(loader.handles.single.loads, 0);
      expect(loader.handles.single.disposals, 1);
      await tester.pump(const Duration(minutes: 5));
      expect(loader.handles.length, 1);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('arka planda istek yok; geri dönünce yeni kaynakla devam eder', (
    tester,
  ) async {
    final loader = _Loader([_Result.failure, _Result.success]);
    await mount(tester, loader);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    await tester.pump(const Duration(minutes: 3));
    expect(loader.handles.length, 1);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(loader.handles.length, 2);
    expect(find.byKey(const ValueKey('ad-1')), findsOneWidget);
  });
  testWidgets('hızlı arka plan dönüşü 30 saniyelik sınırı atlamaz', (
    tester,
  ) async {
    final loader = _Loader([_Result.success, _Result.success]);
    await mount(tester, loader);
    await tester.pump(const Duration(seconds: 5));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(loader.handles.length, 1);
    expect(loader.handles.first.disposals, 1);
    await tester.pump(const Duration(seconds: 24));
    expect(loader.handles.length, 1);
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    expect(loader.handles.length, 2);
  });
  testWidgets('izin kapanınca bekleyen tekrar iptal edilir', (tester) async {
    final loader = _Loader([_Result.failure, _Result.success]);
    final container = await mount(tester, loader);
    (container.read(adsControllerProvider.notifier) as _Consent).allow(false);
    await tester.pump();
    await tester.pump(const Duration(minutes: 5));
    expect(loader.handles.length, 1);
    (container.read(adsControllerProvider.notifier) as _Consent).allow(true);
    await tester.pumpAndSettle();
    expect(loader.handles.length, 2);
  });
  testWidgets('geç gelen SDK yanıtı yeni reklamın durumunu değiştirmez', (
    tester,
  ) async {
    final loader = _Loader([_Result.pending, _Result.success]);
    await mount(tester, loader);
    await tester.pump(const Duration(seconds: 25));
    expect(loader.handles.first.disposals, 1);
    await tester.pump(const Duration(seconds: 30));
    await tester.pump();
    expect(find.byKey(const ValueKey('ad-1')), findsOneWidget);
    loader.handles.first.onFailed(StateError('late'));
    loader.handles.first.onLoaded();
    await tester.pump();
    expect(find.byKey(const ValueKey('ad-1')), findsOneWidget);
    expect(loader.handles[1].disposals, 0);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'platform yükleme istisnası alanı kapatır ve kontrollü tekrar dener',
    (tester) async {
      final loader = _Loader([_Result.exception, _Result.success]);
      await mount(tester, loader);
      expect(loader.handles.first.disposals, 1);
      await tester.pump(const Duration(seconds: 30));
      await tester.pump();
      expect(find.byKey(const ValueKey('ad-1')), findsOneWidget);
    },
  );
  testWidgets('sıfır genişlikte reklam istenmez', (tester) async {
    final loader = _Loader([_Result.success]);
    await mount(tester, loader, width: 0);
    expect(loader.handles, isEmpty);
  });
  testWidgets(
    'zaman aşımından sonra hazırlanan eski kaynak yeni reklamı ezmez',
    (tester) async {
      final loader = _Loader([
        _Result.pending,
        _Result.success,
      ], pendingFirstPrepare: true);
      await mount(tester, loader);
      await tester.pump(const Duration(seconds: 25));
      await tester.pump(const Duration(seconds: 30));
      await tester.pump();
      expect(find.byKey(const ValueKey('ad-1')), findsOneWidget);
      loader.pending.complete(loader.handles.first);
      await tester.pump();
      expect(loader.handles.first.disposals, 1);
      expect(loader.handles.first.loads, 0);
      expect(find.byKey(const ValueKey('ad-1')), findsOneWidget);
    },
  );
  testWidgets(
    'genişlik değişince eski reklam bırakılır ve geç yanıtı yok sayılır',
    (tester) async {
      final loader = _Loader([_Result.pending, _Result.success]);
      await mount(
        tester,
        loader,
        placement: AdPlacement.statistics,
        width: 320,
      );
      await mount(
        tester,
        loader,
        placement: AdPlacement.statistics,
        width: 400,
      );
      expect(loader.handles.first.disposals, 1);
      loader.handles.first.onLoaded();
      await tester.pump();
      expect(find.byKey(const ValueKey('ad-0')), findsNothing);
      expect(find.byKey(const ValueKey('ad-1')), findsOneWidget);
    },
  );
}
