import 'dart:async';

import 'event.dart';
import 'event_handler.dart';
import 'http/request.dart';
import 'http/response.dart';

abstract class Spry {
  bool get debug;
  FutureOr<void> Function(SpryError error, Event event)? get onError;
  FutureOr<void> Function(Event event)? get onRequest;
  FutureOr<void> Function(Event event, next)? get onResponse;

  Future<Response> fetch(Request request) {
    final (handler, params) = resolve(request.method, request.url.path);
    // final event =
  }

  (EventHandler, Map<String, String>) resolve(String method, String path);
}

final class _Spry extends Spry {
  _Spry({
    this.debug = false,
    this.onError,
    this.onRequest,
    this.onResponse,
  });

  @override
  final bool debug;

  @override
  final FutureOr<void> Function(dynamic, Event)? onError;

  @override
  final FutureOr<void> Function(Event)? onRequest;

  @override
  final FutureOr<void> Function(Event, dynamic)? onResponse;

  @override
  (EventHandler, Map<String, String>) resolve(String method, String path) {
    // TODO: implement resolve
    throw UnimplementedError();
  }
}

const Spry Function({
  bool debug,
  FutureOr<void> Function(SpryError error, Event event)? onError,
  FutureOr<void> Function(Event event)? onRequest,
  FutureOr<void> Function(Event event, next)? onResponse,
}) createSpry = _Spry.new;
