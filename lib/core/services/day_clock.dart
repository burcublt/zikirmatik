abstract interface class DayClock {
  DateTime now();

  DateTime dayOf(DateTime value);
}

class SystemDayClock implements DayClock {
  const SystemDayClock();

  @override
  DateTime now() => DateTime.now();

  @override
  DateTime dayOf(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }
}
