import '../http/request.dart';
import '../types.dart';

/// Creates a new Spry [Event] instance.
Event createEvent<Raw>(
    {required Spry app, required Request request, required Raw raw}) {
  return _EventImpl(app: app, raw: raw, request: request);
}

class _EventImpl<Raw> implements Event {
  _EventImpl({required this.app, required this.raw, required this.request});

  late final locals = <Object?, Object?>{};

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

  @override
  final Raw raw;

  @override
  final Request request;

  @override
  final Spry app;
}
