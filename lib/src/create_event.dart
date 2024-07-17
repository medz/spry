import '_constants.dart';
import 'request.dart';
import 'types.dart';

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
