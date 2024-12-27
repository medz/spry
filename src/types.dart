import 'dart:async';

extension type Locals._(Map _) implements Map {}

abstract interface class Event {
  Spry get app;
  Locals get locals;
  Request get request;
  Response get response;

  String get method;
  String get path;
  String get pathname;
  URLSearchParams get query;
  Uri get url;
  Headers get headers;
  String? get ip;
}

abstract interface class SpryOptions {
  final bool debug;
  final FutureOr<void> Function(SpryError error, Event event)? onError;
  final FutureOr<void> Function(Event event)? onRequest;
  final FutureOr<void> Function(Event event, next)? onResponse;
}

abstract interface class Spry {}
