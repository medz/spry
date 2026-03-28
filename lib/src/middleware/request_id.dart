import 'dart:async';
import 'dart:math';

import '../event.dart';
import '../middleware.dart';

final Random _requestIdRandom = Random();

/// Creates middleware that provides a request ID for the current request.
Middleware requestId({
  String headerName = 'x-request-id',
  FutureOr<String> Function(Event event)? generator,
  bool trustIncoming = true,
}) {
  return (event, next) async {
    final incomingValue = event.request.headers.get(headerName);
    final selectedId = switch ((trustIncoming, incomingValue)) {
      (true, final String value) when value.isNotEmpty => value,
      _ => await (generator?.call(event) ?? _defaultRequestIdGenerator()),
    };

    event.locals.set(#requestId, selectedId);
    final response = await next();

    if (!response.headers.has(headerName)) {
      response.headers.set(headerName, selectedId);
    }

    return response;
  };
}

/// Returns the request ID selected for the current request, if available.
String? useRequestId(Event event) {
  return event.locals.get<String>(#requestId);
}

String _defaultRequestIdGenerator() {
  final timestamp = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
  final randomSuffix = _requestIdRandom
      .nextInt(0x100000000)
      .toRadixString(36)
      .padLeft(7, '0');
  return '$timestamp-$randomSuffix';
}
