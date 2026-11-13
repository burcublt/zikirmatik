import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zikirmatik/features/zikrs/data/drift_zikr_repository.dart';
import 'package:zikirmatik/features/zikrs/domain/zikr_definition.dart';

String _generateId() => DateTime.now().microsecondsSinceEpoch.toString();

final zikrsNotifierProvider =
    AsyncNotifierProvider<ZikrsNotifier, List<ZikrDefinition>>(
      ZikrsNotifier.new,
    );

class ZikrsNotifier extends AsyncNotifier<List<ZikrDefinition>> {
  @override
  Future<List<ZikrDefinition>> build() {
    return ref.watch(zikrRepositoryProvider).watchActive().first;
  }

  Future<void> add({
    required String title,
    required int defaultTarget,
    String? description,
  }) async {
    final repo = ref.read(zikrRepositoryProvider);
    final now = DateTime.now();
    await repo.save(
      ZikrDefinition(
        id: _generateId(),
        title: title.trim(),
        description: (description == null || description.trim().isEmpty)
            ? null
            : description.trim(),
        defaultTarget: defaultTarget,
        createdAt: now,
        updatedAt: now,
        isBuiltIn: false,
        sortOrder: 0,
      ),
    );
    ref.invalidateSelf();
  }

  Future<void> editZikr({
    required ZikrDefinition existing,
    required String title,
    required int defaultTarget,
    String? description,
  }) async {
    final isEmpty = description == null || description.trim().isEmpty;
    await ref
        .read(zikrRepositoryProvider)
        .save(
          existing.copyWith(
            title: title.trim(),
            description: isEmpty ? null : description.trim(),
            defaultTarget: defaultTarget,
            updatedAt: DateTime.now(),
            clearDescription: isEmpty,
          ),
        );
    ref.invalidateSelf();
  }

  Future<void> toggleFavorite(ZikrDefinition zikr) async {
    await ref
        .read(zikrRepositoryProvider)
        .save(
          zikr.copyWith(
            isFavorite: !zikr.isFavorite,
            updatedAt: DateTime.now(),
          ),
        );
    ref.invalidateSelf();
  }

  Future<void> delete(ZikrDefinition zikr) async {
    if (zikr.isBuiltIn) return;
    await ref.read(zikrRepositoryProvider).archive(zikr.id);
    ref.invalidateSelf();
  }
}
