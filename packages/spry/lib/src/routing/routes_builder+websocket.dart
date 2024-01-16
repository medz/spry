// ignore_for_file: file_names

import 'dart:async';
import 'dart:io';

import 'package:routingkit/routingkit.dart';

import '../exception/abort.dart';
import '../handler/handler.dart';
import 'route.dart';
import 'routes_builder.dart';

extension RoutesBuilder$WebSocket on RoutesBuilder {
  /// Adds a [WebSocket] route to to the routes.
  ///
  /// The [T] type argument is [fallback] return type.
  ///
  /// ```dart
  /// app.ws('/ws', (websocket, request) {
  ///   websocket.listen((message) {
  ///     websocket.add(message);
  ///   });
  /// });
  /// ```
  ///
  /// - [path] is the websocket listening path.
  /// - [closure] is the websocket handler closure.
  /// - [compression] is the compression options. default is [CompressionOptions.compressionDefault].
  /// - [protocolSelector] is the protocol selector. default is `null`.
  /// - [fallback] is the fallback handler closure. default is `null`.
  void ws<T>(
    String path,
    FutureOr<void> Function(WebSocket ws, HttpRequest request) closure, {
    CompressionOptions compression = CompressionOptions.compressionDefault,
    FutureOr<String> Function(List<String> protocols)? protocolSelector,
    FutureOr<T> Function(HttpRequest request)? fallback,
  }) {
    final handler = _WebSocketHandler(
        closure: closure, fallback: fallback, compression: compression);
    final route =
        Route(handler: handler, segments: path.asSegments, method: 'GET');

    return addRoute(route);
  }
}

class _WebSocketHandler<T> implements Handler<T?> {
  final FutureOr<T> Function(HttpRequest request)? fallback;
  final FutureOr<void> Function(WebSocket websocket, HttpRequest request)
      closure;
  final FutureOr<String> Function(List<String> protocols)? protocolSelector;
  final CompressionOptions compression;

  const _WebSocketHandler({
    required this.closure,
    required this.compression,
    this.fallback,
    this.protocolSelector,
  });

  @override
  Future<T?> handle(HttpRequest request) async {
    if (!WebSocketTransformer.isUpgradeRequest(request)) {
      return (fallback ?? defaultFallback).call(request);
    }

    final websocket = await WebSocketTransformer.upgrade(request,
        compression: compression, protocolSelector: protocolSelector);
    await closure(websocket, request);

    // Await for websocket to close.
    return websocket.done.then((_) => null);
  }

  /// Default fallback handler closure.
  Never defaultFallback(HttpRequest request) {
    throw Abort(HttpStatus.upgradeRequired, message: 'Upgrade Required');
  }
}
