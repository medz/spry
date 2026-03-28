import 'dart:async';
import 'dart:math';

import '../event.dart';
import '../middleware.dart';

final Random _requestIdRandom = Random();

/// Creates middleware that provides a request ID for the current request.
Middleware requestId({
  String headerName = 'x-request-id',
  Symbol localKey = #requestId,
  FutureOr<String> Function(Event event)? generator,
  bool trustIncoming = true,
}) {
  return (event, next) async {
    final selectedId = await _selectRequestId(
      event,
      headerName: headerName,
      localKey: localKey,
      generator: generator,
      trustIncoming: trustIncoming,
    );
    final response = await next();

    if (!response.headers.has(headerName)) {
      response.headers.set(headerName, selectedId);
    }

    return response;
  };
}

Future<String> _selectRequestId(
  Event event, {
  required String headerName,
  required Symbol localKey,
  required FutureOr<String> Function(Event event)? generator,
  required bool trustIncoming,
}) async {
  final incomingValue = event.request.headers.get(headerName);
  final selectedId = switch ((trustIncoming, incomingValue)) {
    (true, final String value) when value.isNotEmpty => value,
    _ => await (generator?.call(event) ?? _defaultRequestIdGenerator()),
  };

  event.locals.set(localKey, selectedId);
  return selectedId;
}

String _defaultRequestIdGenerator() {
  final timestamp = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
  final randomSuffix = _requestIdRandom
      .nextInt(0x100000000)
      .toRadixString(36)
      .padLeft(7, '0');
  return '$timestamp-$randomSuffix';
}
