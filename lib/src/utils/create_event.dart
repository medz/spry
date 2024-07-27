import '../_constants.dart';
import '../http/request.dart';
import '../types.dart';

/// Creates a new Spry [Event] instance.
Event createEvent(Spry app, Request request) {
  return _EventImpl()
    ..set(kRequest, request)
    ..set(kApp, app);
}

class _EventImpl implements Event {
  final locals = <Object?, Object?>{};

  @override
  T? get<T>(Object? key) {
    return switch (locals[key]) {
      T value => value,
      _ => null,
    };
  }

  @override
  void remove(Object? key) {
    locals.remove(key);
  }

  @override
  void set<T>(Object? key, T value) {
    locals[key] = value;
  }
}
