import 'context.dart';

abstract interface class RawEvent {
  Context get context;
  Uri get uri;
  String get method;
}

extension type const Event(RawEvent raw) {
  Uri get uri => raw.uri;
  String get method => raw.method.toUpperCase();
}
