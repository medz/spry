import 'dart:async';

/// Run [fn] and capture any errors that would otherwise be top-level.
T? catchTopLevelErrors<T>(
  T Function() fn,
  void Function(Object, StackTrace) onError,
) {
  if (Zone.current.inSameErrorZone(Zone.root)) {
    return runZonedGuarded<T>(fn, onError);
  }

  return fn();
}
