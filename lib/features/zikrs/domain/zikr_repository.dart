import 'package:zikirmatik/features/zikrs/domain/zikr_definition.dart';

abstract interface class ZikrRepository {
  Stream<List<ZikrDefinition>> watchActive();

  Future<void> save(ZikrDefinition zikr);

  Future<void> archive(String id);
}
